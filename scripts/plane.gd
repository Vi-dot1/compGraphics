extends Area3D
class_name Board
@onready var pieceScene = preload("uid://dm1p2cew6y1qy")
var mouse_over_plane:bool = false

func get_position_on_radius(pos:Vector2):
	var dir = (get_viewport().get_camera_3d().global_position-global_position).normalized()
	# X
	dir = dir.rotated(Vector3.UP, -pos.x/Global.planet_radius)
	# Y
	dir = dir.rotated(Vector3.RIGHT, pos.y/Global.planet_radius)
	return dir*Global.planet_radius*1.1

var can_place = true
func place(data: Gameplay.DominoData, snap: Dictionary):
	var piece:DominoPiece = pieceScene.instantiate()
	
	add_child(piece)
	piece.setup(data)
	
	piece.global_position = snap["pos"]
	piece.top_level = true
	
	piece.mesh_instance.rotation -= snap["rot"]


func _on_mouse_entered() -> void:
	if not mouse_over_plane:
		mouse_over_plane = true
func _on_mouse_exited() -> void:
	if mouse_over_plane:
		mouse_over_plane = false
