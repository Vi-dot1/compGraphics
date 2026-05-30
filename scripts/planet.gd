extends Node3D
class_name Planet
@onready var meshNode = get_node("MeshInstance3D")

@export var radius:float = 3
@export var main:bool = false
func _ready() -> void:
	await get_tree().process_frame
	_update_mesh()

func _update_mesh() -> void:
	meshNode.scale = Vector3.ONE*radius
	Global.planet_radius = radius

func change_texture(texture:String) -> void:
	$MeshInstance3D.mesh.material.albedo_texture = load(texture)
