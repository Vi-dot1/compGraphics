extends HBoxContainer

func set_player_data(player_data:Dictionary, player_name:String, player_color:Color, winner:bool) -> void:
	if winner:
		$nombre.append_text("[pulse][shake][outline_size=4][outline_color=white]")
	$nombre.push_color(player_color)
	$nombre.append_text(player_name)
	var domino_hud = load("uid://bkulr11a35dx")
	for piece:Gameplay.DominoData in player_data["pieces"]:
		var p:DominoHudVisual = domino_hud.instantiate()
		p.v1 = piece.v1
		p.v2 = piece.v2
		p.custom_minimum_size *= 1.2
		$piezas.add_child(p)
	
	$puntos.append_text(str(player_data["points"]))
