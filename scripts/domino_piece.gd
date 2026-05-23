extends StaticBody3D
class_name DominoPiece

@onready var mesh_instance = $MeshInstance3D
@onready var ref:Node3D = $ref

var v1: int = 0
var v2: int = 0
var orientation: int = 0 # 0: horizontal, 1: vertical

func _ready():
	update_visuals()

func _process(_delta: float) -> void:
	look_at(Global.planet_center, Vector3(0, 1, 0))

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
