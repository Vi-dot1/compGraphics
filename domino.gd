extends Node3D
class_name PiecePart

@onready var shape:MeshInstance3D = $piecePartMesh

# No la posicion real, solo variables que usa gameplay
var pos:Vector2i
var value:int

func _ready() -> void:
	var mesh := BoxMesh.new()
	mesh.size.x = float(Gameplay.piece_size)
	mesh.size.z = float(Gameplay.piece_size)
	mesh.size.y = float(Gameplay.piece_size)/3
	
	shape.position.x = float(Gameplay.piece_size)/2
	shape.position.z = float(Gameplay.piece_size)/2
	shape.mesh = mesh
	
	$CollisionShape3D.shape = mesh.create_trimesh_shape()
	$CollisionShape3D.position = shape.position

func can_connect(other:PiecePart) -> bool:
	var xDiff:int = abs(self.pos.x - other.pos.x)
	var yDiff:int = abs(self.pos.y - other.pos.y)

	if xDiff != 1 or yDiff != 1:
		return false
	return value == other.value
