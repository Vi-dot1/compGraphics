extends Node3D
class_name Board
@onready var piecePartScene = preload("res://piece.tscn")

var can_place = true
func _place(pos: Vector2):
	var p:PiecePart = piecePartScene.instantiate()
	
	p.pos.x = int(pos.x)/Gameplay.piece_size
	p.pos.y = int(pos.y)/Gameplay.piece_size
	if pos.x < 0:
		p.pos.x -= 1
	if pos.y < 0:
		p.pos.y -= 1

	p.position.y=0
	p.position.x = p.pos.x*Gameplay.piece_size
	p.position.z = p.pos.y*Gameplay.piece_size
	
	add_child(p)
	
	can_place = false
	await get_tree().create_timer(0.2).timeout
	can_place = true
