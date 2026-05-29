extends Control

func _on_btn_reglas_pressed():
	$CuadroReglas.visible = !$CuadroReglas.visible

func _on_btn_salir_pressed():
	get_tree().quit()
func _on_btn_jugar_pressed() -> void:
	get_tree().change_scene_to_file("uid://bm0c5cv4sl2dp")
