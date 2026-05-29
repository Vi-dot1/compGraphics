extends CanvasLayer

@onready var container = $Control/MarginContainer/HBoxContainer
@onready var status_label = $Control/StatusLabel
@onready var boneyard_label = $Control/BoneyardLabel

@onready var game_end_sign = $"Control/GAME!"

@onready var domino_hud_item = preload("uid://bkulr11a35dx")

func _ready() -> void:
	await get_tree().process_frame
	Gameplay.turn_changed.connect(on_turn_change)
	Gameplay.game_end.connect(on_game_over)
	Gameplay.piece_drawed.connect(on_drawn_piece)
	
	status_label.push_color(Global.player_colors[Gameplay.current_turn])
	status_label.append_text("Jugador " + str(Gameplay.current_turn+1))
	
	if Gameplay.can_draw:
		on_drawn_piece()

func on_drawn_piece() -> void:
	boneyard_label.clear()
	boneyard_label.append_text("Huesera: ")
	boneyard_label.push_color(Color.RED)
	boneyard_label.push_outline_size(2)
	boneyard_label.push_outline_color(Color.WHITE)
	boneyard_label.append_text(str(Gameplay.boneyard.size()))
	
	var t:Tween = get_tree().create_tween()
	t.set_ease(Tween.EASE_IN)
	
	t.tween_property(boneyard_label, "position", boneyard_label.position+Vector2(5,0), 0.1)
	t.tween_property(boneyard_label, "position", boneyard_label.position-Vector2(10,0), 0.1)
	t.tween_property(boneyard_label, "position", boneyard_label.position+Vector2(5,0), 0.1)
	boneyard_label.show()

func on_turn_change() -> void:
	status_label.clear()
	
	status_label.append_text("TURNO DEL ")
	status_label.visible_characters = status_label.text.length()
	
	status_label.push_color(Global.player_colors[Gameplay.current_turn])
	status_label.append_text("Jugador " + str(Gameplay.current_turn+1))
	
	var t:Tween = get_tree().create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(status_label, "visible_ratio", 1.0, 1.2)
	t.play()

func on_game_over() -> void:
	status_label.text = ""
	for piece in container.get_children():
		piece.queue_free()
	
	var t:Tween = get_tree().create_tween()
	t.set_trans(Tween.TRANS_BOUNCE)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(game_end_sign, "position", Vector2(264, 72), 2.4)
	t.play()

#region DominoDisplay

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
#endregion
