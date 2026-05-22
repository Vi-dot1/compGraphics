extends CanvasLayer

@onready var container = $Control/MarginContainer/HBoxContainer
@onready var status_label = $Control/StatusLabel
@onready var boneyard_label = $Control/BoneyardLabel

func _ready():
	update_hand()

func _process(_delta):
	update_status()

func update_status():
	if Gameplay.game_over:
		if Gameplay.winner_id == 0: status_label.text = "YOU WIN! (Domino!)"
		elif Gameplay.winner_id == 1: status_label.text = "AI WINS!"
		else: status_label.text = "DRAW / BLOCKED"
	else:
		if Gameplay.current_turn == 0:
			if Gameplay.board_pieces.size() > 0:
				status_label.text = "YOUR TURN  |  Open: [" + str(Gameplay.open_ends[0]) + "] - [" + str(Gameplay.open_ends[1]) + "]"
			else:
				status_label.text = "YOUR TURN  |  Place any tile"
		else:
			status_label.text = "AI TURN..."
	
	boneyard_label.text = "Boneyard: " + str(Gameplay.boneyard.size())

func update_hand():
	# Clear existing
	for child in container.get_children():
		child.queue_free()
	
	for i in range(Gameplay.hands[0].size()):
		var data = Gameplay.hands[0][i]
		var is_selected = (i == get_parent().selected_piece_index)
		
		var piece_ui = create_domino_ui(data, is_selected)
		container.add_child(piece_ui)

func create_domino_ui(data: Gameplay.DominoData, selected: bool) -> Control:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(80, 40)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.2, 0.8)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color.CYAN if selected else Color(0.3, 0.3, 0.5)
	
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(hbox)
	
	var l1 = Label.new()
	l1.text = str(data.v1)
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var sep = VSeparator.new()
	
	var l2 = Label.new()
	l2.text = str(data.v2)
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	hbox.add_child(l1)
	hbox.add_child(sep)
	hbox.add_child(l2)
	
	if selected:
		panel.scale = Vector2(1.1, 1.1)
		panel.z_index = 1
	
	return panel
