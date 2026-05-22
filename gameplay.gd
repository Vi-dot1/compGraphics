extends Node

class DominoData:
	var v1: int
	var v2: int
	func _init(_v1: int, _v2: int):
		v1 = _v1
		v2 = _v2
	func get_sum() -> int:
		return v1 + v2
	func is_double() -> bool:
		return v1 == v2
	func get_as_string() -> String:
		return str(v1) + "-" + str(v2)

# --- State Variables ---
var boneyard: Array[DominoData] = []
var hands: Dictionary = {0: [], 1: []}

var board_pieces: Array = []
var open_ends: Array[int] = [-1, -1]
var current_turn: int = 0
var consecutive_passes: int = 0
var game_over: bool = false
var winner_id: int = -1

func _ready():
	pass

func init_game():
	boneyard.clear()
	board_pieces.clear()
	hands = {0: [], 1: []}
	open_ends = [-1, -1]
	game_over = false
	winner_id = -1
	consecutive_passes = 0
	
	# Generate 28 tiles
	for i in range(7):
		for j in range(i, 7):
			boneyard.append(DominoData.new(i, j))
	boneyard.shuffle()
	
	# Deal 7 each
	for i in range(7):
		hands[0].append(boneyard.pop_back())
		hands[1].append(boneyard.pop_back())
	
	determine_starter()

func determine_starter():
	return -1

# Determina jugada inicial
func _determine_starter():
	var best_double = -1
	var starter = 0
	
	# Determina que jugador posee el doble mayor
	for p_id in hands:
		for tile in hands[p_id]:
			if tile.is_double() and tile.v1 > best_double:
				best_double = tile.v1
				starter = p_id
	
	if best_double != -1:
		current_turn = starter
		return
	
	# Si de casualidad, ningun juegador tiene un doble
	# se elige el jugador con la pieza de mayor suma
	var best_sum = -1
	for p_id in hands:
		for tile in hands[p_id]:
			if tile.get_sum() > best_sum:
				best_sum = tile.get_sum()
				starter = p_id
	
	current_turn = starter

# Retorna la lista de piezas que son jugables
func get_valid_moves(player_id: int) -> Array:
	var valid = []
	if board_pieces.size() == 0:
		return hands[player_id].duplicate()
	
	for tile in hands[player_id]:
		if tile.v1 == open_ends[0] or tile.v2 == open_ends[0]:
			valid.append(tile)
		elif tile.v1 == open_ends[1] or tile.v2 == open_ends[1]:
			valid.append(tile)
	
	return valid


func play_tile(player_id: int, tile: DominoData, side: int, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO) -> bool:
	if board_pieces.size() == 0:
		open_ends = [tile.v1, tile.v2]
	else:
		if side == 0:
			if tile.v1 == open_ends[0]: open_ends[0] = tile.v2
			elif tile.v2 == open_ends[0]: open_ends[0] = tile.v1
			else: return false
		else:
			if tile.v1 == open_ends[1]: open_ends[1] = tile.v2
			elif tile.v2 == open_ends[1]: open_ends[1] = tile.v1
			else: return false
	
	board_pieces.append({"data": tile, "pos": pos, "rot": rot})
	hands[player_id].erase(tile)
	consecutive_passes = 0
	
	if hands[player_id].size() == 0:
		end_game(player_id, "Domino!")
	else:
		advance_turn()
	return true

func draw_piece(player_id: int) -> DominoData:
	if boneyard.size() > 0:
		var tile = boneyard.pop_back()
		hands[player_id].append(tile)
		return tile
	return null

func advance_turn():
	current_turn += 1
	current_turn %= hands.size()

func player_pass():
	consecutive_passes += 1
	if consecutive_passes >= hands.size():
		end_game(-1, "Blocked")
	else:
		advance_turn()

func end_game(winner: int, _reason: String):
	game_over = true
	if winner != -1:
		winner_id = winner
	else:
		var p0 = get_hand_sum(0)
		var p1 = get_hand_sum(1)
		if p0 < p1: winner_id = 0
		elif p1 < p0: winner_id = 1
		else: winner_id = -1

func get_hand_sum(player_id: int) -> int:
	var s = 0
	for t in hands[player_id]: s += t.get_sum()
	return s

func get_half_positions(pos: Vector3, rot: Vector3) -> Array[Vector3]:
	var b = Basis(Quaternion.from_euler(rot))
	return [pos + b * Vector3(-0.5, 0, 0), pos + b * Vector3(0.5, 0, 0)]
