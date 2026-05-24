extends Area3D
class_name Board
@onready var pieceScene = preload("uid://dm1p2cew6y1qy")

var lastPlaced:DominoPiece = null

func fix_piece_distance_to_radius(pos:Vector3) -> Vector3:
	# Ya me canse de las piezas saliendose, se supone que ttecleo, no que hao algebra aaaa
	# asi que descubri que como a fin de cuentas la pieza es recta se va acumulando un angulo que
	# lentamente la va sacando del planeta, asi que la mejor solucion es tener algo que corte la distancia del planeta con el radio
	# de la pieza
	#
	# Si medio saben vectores, deberian enteneder esto, si no, la explicacion cuesta un juguito
	return to_global(to_local(pos).normalized()*Global.planet_radius*1.1)

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
	piece.rotate_visual(snap["rot"])
	
	# Get piece ref
	lastPlaced = piece
