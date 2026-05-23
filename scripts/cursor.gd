extends Area3D
class_name Cursor

@onready var visual_root = $Node3D
var current_piece_visual: DominoPiece = null
var free: bool = true
var rotation_index: int = 0

func set_piece(data: Gameplay.DominoData):
	if current_piece_visual:
		current_piece_visual.queue_free()
		current_piece_visual = null

	if data == null:
		return

	var scene = load("res://domino_piece.tscn")
	current_piece_visual = scene.instantiate()
	visual_root.add_child(current_piece_visual)
	current_piece_visual.setup(data)
	# Disable collision on cursor preview
	current_piece_visual.set_physics_process(false)

func _cursor_piece_state_valid(valid: bool):
	if current_piece_visual == null:
		return
	
	var mat = current_piece_visual.mesh_instance.get_surface_override_material(0)
	if mat:
		mat.set_shader_parameter("edge_color", Color.GREEN if valid else Color.RED)
		mat.set_shader_parameter("emission_strength", 2.0)

func rotate_piece():
	rotation_index = (rotation_index + 1) % 4
	visual_root.rotation_degrees.y = rotation_index * 90
