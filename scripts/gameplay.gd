extends Node

signal turn_changed
signal game_end

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
var players: Array[Dictionary]
var current_player: Dictionary

var current_turn: int = 0
var consecutive_passes: int = 0
var open_ends:Array[int] = [-1, -1]

var can_draw: bool = true
var game_over: bool = false
var winner_id: int = -1

func set_current_player_val() -> void:
	current_player = players[current_turn]

func init_game(player_amnt:int = 2):
	boneyard.clear()
	
	# Para evitar que un chistoso meta -2 jugadores
	if player_amnt < 2:
		player_amnt = 2
	
	for i in range(player_amnt):
		var player_data:Dictionary = {"pieces":[], "points":0}
		players.append(player_data)
	
	game_over = false
	winner_id = -1
	
	boneyard.clear()
	for i in range(7):
		for j in range(i, 7):
			boneyard.append(DominoData.new(i, j))
	boneyard.shuffle()
	
	# A cada jugador
	for player in players:
		# Dale 7 Piezas
		for j in range(2):
			player["pieces"].append(boneyard.pop_back())
	# Determina el inicial
	determine_starter()
	set_current_player_val()

# Determina jugada inicial
func determine_starter():
	var best_double = -1
	var starter = -1
	# Determina que jugador posee el doble mayor
	for i in players.size():
		for tile in players[i]["pieces"]:
			if tile.is_double() and tile.v1 > best_double:
				best_double = tile.v1
				starter = i
	if best_double != -1:
		current_turn = starter
		return
	# Si de casualidad, ningun juegador tiene un doble
	# se elige el jugador con la pieza de mayor suma
	var best_sum = -1
	for i in players.size():
		for tile in players[i]["pieces"]:
			if tile.get_sum() > best_sum:
				best_sum = tile.get_sum()
				starter = i
	current_turn = starter

# Trata de jugar una pieza
func play_tile(tile: DominoData, side:int) -> void:
	if open_ends[0] == -1:
		open_ends = [tile.v1, tile.v2]
	else:
		# Actualiza info del estado del juego
		if tile.v1 == open_ends[side]:
			open_ends[side] = tile.v2
		elif tile.v2 == open_ends[side]:
			open_ends[side] = tile.v1
		else:
			return
	
	current_player["pieces"].erase(tile)
	consecutive_passes = 0
	
	if current_player["pieces"].size() == 0:
		end_game()
	else:
		advance_turn()

func draw_piece() -> void:
	if boneyard.size() > 0 and can_draw:
		var tile = boneyard.pop_back()
		current_player["pieces"].append(tile)

func advance_turn():
	current_turn += 1
	current_turn %= players.size()
	
	set_current_player_val()
	turn_changed.emit()

func player_pass():
	consecutive_passes += 1
	if consecutive_passes >= players.size():
		end_game()
		return
	advance_turn()

func end_game():
	game_over = true
	var lowest_score:int = 1000000
	var winner:int = -1
	
	for i in players.size():
		var score:int = get_hand_sum(i)
		if score < lowest_score:
			lowest_score = score
			winner_id = i
		players[i]["score"] = score
	
	game_end.emit()

func get_hand_sum(player_idx: int) -> int:
	var sum = 0
	for domino in players[player_idx]["pieces"]:
		sum += domino.get_sum()
	return sum

func get_half_positions(pos: Vector3, rot: Vector3) -> Array[Vector3]:
	var b = Basis(Quaternion.from_euler(rot))
	return [pos + b * Vector3(-0.5, 0, 0), pos + b * Vector3(0.5, 0, 0)]
