extends Node3D
class_name Board
@onready var pieceScene = preload("uid://dm1p2cew6y1qy")

var can_place = true
func place(data: Gameplay.DominoData, snap: Dictionary):
	var piece:DominoPiece = pieceScene.instantiate()
	
	add_child(piece)
	piece.setup(data)
	
	piece.position = snap["pos"]
	piece.mesh_instance.rotation -= snap["rot"]
	
	can_place = false
	await get_tree().create_timer(0.2).timeout
	can_place = true
