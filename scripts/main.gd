extends Node3D


@onready var cameraRot = $cam
@onready var cursor: Cursor = $cursor
@onready var board:Board = $cam/plane
@onready var hud = $HUD
@onready var planet = $Planet

var selected_piece_index: int = 0
var last_side_placed = -1

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
	hud.update_hand()
	
	planet.radius = 10
	cameraRot.cam_distance = planet.radius + 10
	
	Global.planet_center = planet.global_position
	Global.planet_radius = planet.radius
	
	Gameplay.turn_changed.connect(_on_turn_changed)
	Gameplay.game_end.connect(_on_game_end)

func _on_turn_changed() -> void:
	selected_piece_index = 0
	update_cursor_piece()
func _on_game_end() -> void:
	$backgroundMusic.stop()
	$sfx2.play()

func update_cursor_piece():
	var my_hand = Gameplay.hands[Gameplay.current_turn]
	if my_hand.size():
		selected_piece_index = clampi(selected_piece_index, 0, my_hand.size() - 1)
		cursor.set_piece(my_hand[selected_piece_index])
	hud.update_hand()

# --- Physics / Cursor Movement ---
func _process(_delta: float) -> void:
	if Gameplay.game_over:
		cursor.visible = false
		return
	cursor.visible = true
	
	# Esta funcion solo se usa aca al final de todo, pero erro que ayuda
	var hit = board.get_position_on_radius(Vector2.ZERO)
	if hit == null:
		return
	
	var my_hand = Gameplay.hands[Gameplay.current_turn]
	if my_hand.size() == 0:
		return
	
	var data = my_hand[selected_piece_index]
	
	# --- First piece: free placement ---
	if Gameplay.board_pieces.size() == 0:
		cursor.position = round(hit)
		
		current_snap = {"valid": true, "side": -1, "pos": cursor.position, "rot": cursor.current_piece_visual.rotation}
		cursor.free = true
		cursor._cursor_piece_state_valid(true)
		
		return
	
	# --- Subsequent pieces: snap to endpoints ---
	current_snap = _find_best_snap(hit, data)
	cursor.free = current_snap.valid
	cursor._cursor_piece_state_valid(current_snap.valid)
	
	if current_snap.valid:
		cursor.position = current_snap.pos
		cursor.current_piece_visual.rotate_visual(current_snap.rot)
	else:
		cursor.current_piece_visual.reset_rotation()
		cursor.position = round(hit)

func _find_best_snap(mouse_world: Vector3, data: Gameplay.DominoData) -> Dictionary:
	var best:Dictionary = {"valid": false}
	
	for snap_data in [{"snap": left_snap, "side": 0}, {"snap": right_snap, "side": 1}]:
		var snap: Dictionary = snap_data.snap
		if snap.is_empty():
			continue
		
		var dist = mouse_world.distance_to(snap["pos"])
		if dist > 2:
			continue
		
		var side: int = snap_data.side
		var match_v1:bool = (data.v1 == snap["value"])
		var match_v2:bool = (data.v2 == snap["value"])
		if not match_v1 and not match_v2:
			continue
		
		var rot:Vector3
		var matched_half: int
		var center:Vector3
		 
		if data.is_double():
			center = board.fix_piece_distance_to_radius(snap["doublePos"])
			rot = Vector3((PI/2), (PI/2), (PI/2))
			matched_half = -1
		else:
			center = board.fix_piece_distance_to_radius(snap["pos"] if not snap["is_double"] else snap["doublePos"])
			# Left
			if match_v1:
				if side == 0: rot = Vector3(0, PI, 0)
				matched_half = 0
			# Right
			if match_v2:
				if side == 1: rot = Vector3(0, PI, 0)
				matched_half = 1
		best = {"valid": true, "pos": center, "rot": rot, "side": side, "matched_half": matched_half}
	return best

# --- Input ---
func _unhandled_input(event: InputEvent) -> void:
	if Gameplay.game_over:
		return
	if event.is_action_pressed("place"):
		if current_snap.valid and Gameplay.hands[Gameplay.current_turn].size() > 0:
			var data = Gameplay.hands[Gameplay.current_turn][selected_piece_index]
			_do_place_piece(data, current_snap)
	
	if event.is_action_pressed("rotate_piece"):
		#cursor.rotate_piece()
		pass
	if event.is_action_pressed("next_piece"):
		change_selection(1)
	if event.is_action_pressed("prev_piece"):
		change_selection(-1)
	if event.is_action_pressed("get_piece"):
		Gameplay.draw_piece()
		hud.update_hand()
	if event.is_action_pressed("pass_turn"):
		Gameplay.player_pass()

# --- Placement ---
func _do_place_piece(data: Gameplay.DominoData, snap: Dictionary):
	# Spawn 3D piece
	board.place(data, snap, cursor.horizontal)
	last_side_placed = snap["side"]
	
	# Effects
	_spawn_particles(snap["pos"])
	cameraRot.shake()
	$sfx1.play()
	
	# Update snap points BEFORE play_tile (which changes open_ends)
	_update_snap_points(data, snap["pos"], snap["side"], snap)
	# Update game state (Now handle board_pieces and hands in gameplay.gd)
	Gameplay.play_tile(Gameplay.current_turn, data, snap["side"] if snap["side"] > 0 else 0, snap["pos"], snap["rot"])

func _update_snap_points(data: Gameplay.DominoData, pos: Vector3, side: int, snap: Dictionary):
	# First piece: create both endpoints
	if Gameplay.board_pieces.size() == 0:
		left_snap = {
			"pos": board.lastPlaced.getLeftSnapPoint(),
			"doublePos": board.lastPlaced.getLeftSnapPoint(true),
			"value": data.v1,
			"is_double": false
		}
		right_snap = {
			"pos": board.lastPlaced.getRightSnapPoint(),
			"doublePos": board.lastPlaced.getRightSnapPoint(true),
			"value": data.v2,
			"is_double": false
		}
		return
	
	var new_snap = {
		"pos": pos, 
		"value": data.v2 if snap.get("matched_half", 0) == 0 else data.v1,
		"is_double": data.is_double()
	}
	# Left
	if side == 0:
		new_snap["pos"] = board.lastPlaced.getLeftSnapPoint()
		new_snap["doublePos"] = board.lastPlaced.getLeftSnapPoint(true)
		left_snap = new_snap
	# Right
	else:
		new_snap["pos"] = board.lastPlaced.getRightSnapPoint()
		new_snap["doublePos"] = board.lastPlaced.getRightSnapPoint(true)
		right_snap = new_snap

func _spawn_particles(pos: Vector3):
	var particles = Global._create_placement_particles(pos)
	add_child(particles)
	particles.emitting = true

func change_selection(dir: int):
	var my_hand = Gameplay.hands[Gameplay.current_turn]
	if my_hand.size() == 0:
		return
	selected_piece_index = (selected_piece_index+dir) % my_hand.size()
	update_cursor_piece()
