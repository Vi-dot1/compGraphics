extends Node3D
class_name DominoPiece
@onready var mesh_instance = $MeshInstance3D

var v1: int = 0
var v2: int = 0

var default_mesh_rotation:Vector3
func _ready():
	update_visuals()
	default_mesh_rotation = mesh_instance.rotation

func getLeftSnapPoint(is_double:bool = false) -> Vector3:
	if is_double:
		return $refLeftDouble.global_position
	return $refLeft.global_position
func getRightSnapPoint(is_double:bool = false) -> Vector3:
	if is_double:
		return $refRightDouble.global_position
	return $refRight.global_position

func rotate_visual(rot:Vector3) -> void:
	mesh_instance.rotation = default_mesh_rotation-rot
func reset_rotation() -> void:
	mesh_instance.rotation = default_mesh_rotation
func setup(data: Gameplay.DominoData):
	v1 = data.v1
	v2 = data.v2
	update_visuals()

func update_visuals():
	# CRITICAL: Always create a UNIQUE material for this instance.
	# The .tscn scene shares a single ShaderMaterial sub-resource among all
	# instances. If we just call set_shader_parameter on that shared resource,
	# every piece on the board changes to the same values.
	var source_mat = mesh_instance.get_surface_override_material(0)
	if source_mat == null:
		source_mat = mesh_instance.mesh.surface_get_material(0)
	
	# duplicate() creates a brand-new ShaderMaterial with its own parameters
	var unique_mat = source_mat.duplicate()
	mesh_instance.set_surface_override_material(0, unique_mat)
	
	unique_mat.set_shader_parameter("val1", v1)
	unique_mat.set_shader_parameter("val2", v2)
	unique_mat.set_shader_parameter("emission_strength", 0.0)
