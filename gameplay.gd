extends Node
enum Orientation {NORTH, SOUTH, WEST, EAST}

var piece_size: int = 1

class Piece:
	var o:Orientation
	var p1:PiecePart
	var p2:PiecePart


const MAX_PLAYERS:int = 6
var players:int = 0

# Los turnos se toman de 0 a 5
var player_turn:int = 0

# Como tal solo existen una serie limitada de posiciones validas
# Guardaremos esas posiciones aca
var EndPoints:Array[PiecePart]

func init_game(n_players:int) -> void:
	players = n_players
	EndPoints.clear()

func place_piece(piece:Piece) -> bool:

	for endpoint in EndPoints:
		if endpoint.can_connect(piece.p1):
			pass
		if endpoint.can_connect(piece.p2):
			pass
	return false		
