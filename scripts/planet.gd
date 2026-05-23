extends Node3D
@onready var meshNode = get_node("MeshInstance3D")

@onready var radius:float = 3 :
	set(val):
		radius = val
		_update_mesh()

func _ready() -> void:
	pass

func _update_mesh() -> void:
	meshNode.scale = Vector3.ONE*radius
