extends Node3D

@onready var cam = $camMount/Camera3D
@onready var cursor: Cursor = $cursor
@onready var hud = $HUD

var selected_piece_index: int = 0

# Direct tracking of the two open ends of the chain in 3D space.
# "pos" = the EDGE of the last piece on that side (where the next piece touches).
# "normal" = direction pointing OUTWARD from the chain.
# "value" = the pip number exposed on that end.
var left_snap: Dictionary = {}
var right_snap: Dictionary = {}

# The computed snap result for the current frame
var current_snap: Dictionary = {"valid": false}

func _ready() -> void:
	Gameplay.init_game()
	update_cursor_piece()
	if hud: hud.update_hand()

func update_cursor_piece():
	var my_hand = Gameplay.hands[Gameplay.current_turn]
	if my_hand.size() > 0:
		selected_piece_index = clampi(selected_piece_index, 0, my_hand.size() - 1)
		cursor.set_piece(my_hand[selected_piece_index])
	else:
		cursor.set_piece(null)
	if hud: hud.update_hand()

# --- Physics / Cursor Movement ---

func _physics_process(_delta: float) -> void:
	if Gameplay.game_over:
		cursor.visible = false
		return
	cursor.visible = true
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse_pos)
	var dir_vec = cam.project_ray_normal(mouse_pos)
	var hit = Plane(Vector3.UP, 0).intersects_ray(from, from + dir_vec * 1000)
	if hit == null:
		return
	
	var my_hand = Gameplay.hands[Gameplay.current_turn]
	if my_hand.size() == 0:
		return
	
	var data = my_hand[selected_piece_index]
	var sv = 1
	# --- First piece: free placement ---
	if Gameplay.board_pieces.size() == 0:
		
		cursor.position = Vector3(round(hit.x / sv) * sv, 0, round(hit.z / sv) * sv)
		current_snap = {"valid": true, "side": -1, "pos": cursor.position, "rot": cursor.visual_root.rotation}
		cursor.free = true
		cursor._cursor_piece_state_valid(true)
		
		return

	# --- Subsequent pieces: snap to endpoints ---
	current_snap = _find_best_snap(hit, data)
	cursor.free = current_snap.valid
	cursor._cursor_piece_state_valid(current_snap.valid)
	
	if current_snap.valid:
		cursor.position = current_snap.pos
		cursor.visual_root.rotation = current_snap.rot
	else:
		cursor.position = Vector3(round(hit.x / sv) * sv, 0, round(hit.z / sv) * sv)

func _find_best_snap(mouse_world: Vector3, data: Gameplay.DominoData) -> Dictionary:
	var best = {"valid": false}
	var best_dist = 3.0

	for snap_data in [{"snap": left_snap, "side": 0}, {"snap": right_snap, "side": 1}]:
		var snap: Dictionary = snap_data.snap
		if snap.is_empty():
			continue
		var dist = mouse_world.distance_to(snap["pos"])
		if dist >= best_dist:
			continue

		var side: int = snap_data.side
		var normal: Vector3 = snap["normal"]
		var match_v1 = (data.v1 == snap["value"])
		var match_v2 = (data.v2 == snap["value"])
		if not match_v1 and not match_v2:
			continue

		var base_rot_y = atan2(-normal.z, normal.x)
		var rot: Vector3
		var matched_half: int

		if data.is_double():
			# Doubles are placed crosswise (90 degrees to the chain)
			rot = Vector3(0, base_rot_y + PI/2, 0)
			matched_half = 0 # Doesn't matter for doubles
			var center = snap["pos"] + normal * 0.5 # Double is only 1 unit wide along chain
			best = {"valid": true, "pos": center, "rot": rot, "side": side, "matched_half": matched_half, "normal": normal}
		else:
			if match_v1:
				rot = Vector3(0, base_rot_y, 0)
				matched_half = 0
			else:
				rot = Vector3(0, base_rot_y + PI, 0)
				matched_half = 1
			var center = snap["pos"] + normal * 1.0 # Standard piece is 2 units long
			best = {"valid": true, "pos": center, "rot": rot, "side": side, "matched_half": matched_half, "normal": normal}
		
		best_dist = dist
	return best

# --- Input ---
func _unhandled_input(event: InputEvent) -> void:
	if Gameplay.game_over:
		return
	
	if event.is_action_pressed("place"):
		if current_snap.valid and Gameplay.hands[Gameplay.current_turn].size() > 0:
			var data = Gameplay.hands[Gameplay.current_turn][selected_piece_index]
			_do_place_piece(data, current_snap)
	
	if event.is_action_pressed("next_piece"):
		change_selection(1)
	if event.is_action_pressed("prev_piece"):
		change_selection(-1)
	if event.is_action_pressed("get_piece"):
		_draw_piece()

# --- Placement ---
func _do_place_piece(data: Gameplay.DominoData, snap: Dictionary):
	var pos: Vector3 = snap["pos"]
	var rot: Vector3 = snap["rot"]
	var side: int = snap["side"]

	# Spawn 3D piece
	var scene = load("res://domino_piece.tscn")
	var piece = scene.instantiate()
	add_child(piece)
	piece.position = pos
	piece.rotation = rot
	piece.setup(data)

	# Effects
	_spawn_particles(pos, rot)
	cam.shake()
	
	# Update snap points BEFORE play_tile (which changes open_ends)
	_update_snap_points(data, pos, rot, side, snap)
	# Update game state (Now handle board_pieces and hands in gameplay.gd)
	Gameplay.play_tile(0, data, side if side >= 0 else 0, pos, rot)
	update_cursor_piece()


func _update_snap_points(data: Gameplay.DominoData, pos: Vector3, rot: Vector3, side: int, snap: Dictionary):
	var b = Basis(Quaternion.from_euler(rot))

	if Gameplay.board_pieces.size() == 0:
		# First piece: create both endpoints
		# If it's a double, endpoints are closer to center
		var dist = 0.5 if data.is_double() else 1.0
		left_snap = {
			"pos": pos + b * Vector3(-dist, 0, 0),
			"value": data.v1,
			"normal": b * Vector3(-1, 0, 0)
		}
		right_snap = {
			"pos": pos + b * Vector3(dist, 0, 0),
			"value": data.v2,
			"normal": b * Vector3(1, 0, 0)
		}
	else:
		# Subsequent piece: update the endpoint that was connected
		var normal: Vector3 = snap["normal"]
		var matched_half: int = snap.get("matched_half", 0)
		var exposed_value = data.v2 if matched_half == 0 else data.v1
		# If we just placed a double, the new edge is only 0.5 away from center
		# If we placed a standard piece, the new edge is 1.0 away from center
		var step = 0.5 if data.is_double() else 1.0
		var new_edge_pos = pos + normal * step
		var new_snap = {"pos": new_edge_pos, "value": exposed_value, "normal": normal}

		if side == 0:
			left_snap = new_snap
		else:
			right_snap = new_snap


func _draw_piece():
	var tile = Gameplay.draw_from_boneyard(0)
	if tile:
		update_cursor_piece()

func _spawn_particles(pos: Vector3, rot: Vector3):
	var particles = Global._create_placement_particles(pos, rot)
	add_child(particles)
	particles.emitting = true
	
	get_tree().create_timer(2.0).timeout.connect(particles.queue_free)

func change_selection(dir: int):
	var my_hand = Gameplay.hands[Gameplay.current_turn]
	if my_hand.size() == 0:
		return
	selected_piece_index = (selected_piece_index + dir) % my_hand.size()
	if selected_piece_index < 0:
		selected_piece_index += my_hand.size()
	
	update_cursor_piece()
