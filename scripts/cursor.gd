extends Area3D
class_name Cursor

@onready var visual_root = $Node3D
@onready var current_piece_visual: DominoPiece = $DominoPiece

var free: bool = true
var rotation_index: int = 0

func _process(delta: float) -> void:
	look_at(Global.planet_center, Vector3(0,1,0))

func set_piece(data: Gameplay.DominoData):
	if data == null:
		return
	
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
