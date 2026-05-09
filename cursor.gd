extends Area3D
class_name Cursor
@export var place_color:Color
@export var block_color:Color

@onready var mesh = $Node3D/cursorMesh.mesh
var free:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh.material.albedo_color = place_color

func _physics_process(_delta: float) -> void:
	free = get_overlapping_bodies().size() == 0
	if free:
		mesh.material.albedo_color = place_color
	else:
		mesh.material.albedo_color = block_color
