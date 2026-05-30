extends Control

func _ready() -> void:
	$Principal/BtnSalir.pressed.connect(_on_btn_salir_pressed)
	
	$Principal/BtnJugar.pressed.connect(_transition_screen)
	$OpcionesPartida/BtnSalir.pressed.connect(_transition_screen)
	
	$OpcionesPartida/BtnComenzar.pressed.connect(_start)

func _on_btn_salir_pressed():
	get_tree().quit()

var on_main:bool = true
func _transition_screen() -> void:
	if $AnimationPlayer.is_playing():
		return
	
	if on_main:
		$AnimationPlayer.play("transition")
	else:
		$AnimationPlayer.play_backwards("transition")
	$sfx.play()
	
	on_main = !on_main

func _start() -> void:
	$sfx2.play()
	await  $sfx2.finished
	get_tree().change_scene_to_file("uid://bm0c5cv4sl2dp")
