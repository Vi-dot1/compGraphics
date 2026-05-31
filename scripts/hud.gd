extends CanvasLayer

@onready var container = $Control/MarginContainer/HBoxContainer
@onready var status_label = $Control/StatusLabel
@onready var boneyard_label = $Control/BoneyardLabel

@onready var timer_label = $timerLabel
@onready var game_end_sign = $"Control/GAME!"

@onready var domino_hud_item = preload("uid://bkulr11a35dx")
@onready var pointCount = preload("uid://cbnavmglhtv7q")


func _ready() -> void:
	await get_tree().process_frame
	Gameplay.turn_changed.connect(on_turn_change)
	Gameplay.game_end.connect(on_game_over)
	Gameplay.piece_drawed.connect(on_drawn_piece)
	
	status_label.push_color(Global.player_colors[Gameplay.current_turn])
	status_label.append_text("Jugador " + str(Gameplay.current_turn+1))
	
	if Gameplay.can_draw:
		on_drawn_piece()
	

func _process(delta: float) -> void:
	if Gameplay.timer != null:
		timer_label.show()
		timer_label.clear()
		timer_label.append_text("[shake]"+str(int(Gameplay.timer.time_left)))

var t_boneyard:Tween = null
func on_drawn_piece() -> void:
	if not Gameplay.can_draw:
		return
	
	boneyard_label.clear()
	boneyard_label.append_text("Huesera: ")
	boneyard_label.push_color(Color.RED)
	boneyard_label.push_outline_size(2)
	boneyard_label.push_outline_color(Color.WHITE)
	boneyard_label.append_text(str(Gameplay.boneyard.size()))
	
	boneyard_label.show()
	
	if t_boneyard != null and t_boneyard.is_running():
		return
	t_boneyard = get_tree().create_tween()
	t_boneyard.set_ease(Tween.EASE_IN)
	
	t_boneyard.tween_property(boneyard_label, "position", boneyard_label.position+Vector2(5,0), 0.2)
	t_boneyard.tween_property(boneyard_label, "position", boneyard_label.position-Vector2(5,0), 0.1)
	t_boneyard.tween_property(boneyard_label, "position", boneyard_label.position+Vector2(0,5), 0.2)
	t_boneyard.tween_property(boneyard_label, "position", boneyard_label.position-Vector2(0,5), 0.1)
	

func on_turn_change() -> void:
	status_label.clear()
	
	status_label.append_text("TURNO DEL ")
	status_label.visible_characters = status_label.text.length()
	
	status_label.push_color(Global.player_colors[Gameplay.current_turn])
	status_label.append_text("Jugador " + str(Gameplay.current_turn+1))

func on_game_over() -> void:
	set_process(false)
	status_label.text = ""
	boneyard_label.clear()
	
	for piece in container.get_children():
		piece.queue_free()
	
	# Acomoda el leaderboard
	var leaderBoard = $"Control/GAME!/Panel/MarginContainer/VBoxContainer"
	for i in range(Gameplay.player_amnt):
		var p = pointCount.instantiate()
		
		p.set_player_data(Gameplay.players[i], "Jugador "+str(i+1), Global.player_colors[i], Gameplay.winner_id == i)
		leaderBoard.add_child(p)
		
	
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
