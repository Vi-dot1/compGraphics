extends CanvasLayer

@onready var container = $Control/MarginContainer/HBoxContainer
@onready var status_label = $Control/StatusLabel
@onready var boneyard_label = $Control/BoneyardLabel

@onready var domino_hud_item = preload("uid://bkulr11a35dx")

func _process(_delta):
	update_status()

func update_status():
	if Gameplay.game_over:
		if Gameplay.winner_id == -1: status_label.text = "EMPATE"
		else: status_label.text = "JUGADOR "+ str(Gameplay.winner_id+1) + " GANO"
		return
	
	if Gameplay.open_ends[0] == -1:
		status_label.text = "TURNO DE JUGADOR " + str(Gameplay.current_turn+1) + " |  Open: [" + str(Gameplay.open_ends[0]) + "] - [" + str(Gameplay.open_ends[1]) + "]"
	else:
		status_label.text = "PRIMER TURNO, JUGADOR " + str(Gameplay.current_turn+1)
	
	boneyard_label.text = "Piezas en Huesera: " + str(Gameplay.boneyard.size())

func update_hand():
	# Clear existing
	for child in container.get_children():
		child.queue_free()
	
	var first:bool = true
	for data in Gameplay.current_player["pieces"]:
		var piece_ui = create_domino_ui(data, first)
		first = false
		container.add_child(piece_ui)

func update_selected(idx:int, val:bool) -> void:
	var domino:DominoHudVisual = container.get_child(idx)
	domino.set_select(val)

func create_domino_ui(data: Gameplay.DominoData, selected: bool) -> DominoHudVisual:
	var domino:DominoHudVisual = domino_hud_item.instantiate()
	domino.v1 = data["v1"]
	domino.v2 = data["v2"]
	domino.set_select(selected)
	domino.rotation_degrees +=90
	domino.custom_minimum_size *= 2
	return domino
