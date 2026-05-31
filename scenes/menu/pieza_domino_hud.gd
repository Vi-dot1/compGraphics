extends Control
class_name DominoHudVisual

@export var v1:int = 0
@export var v2:int = 0
func _ready() -> void:
	$piece.color = Global.piece_color
	var mat = $dots.material.duplicate()
	mat.set_shader_parameter("val1", v1)
	mat.set_shader_parameter("val2", v2)
	$dots.material = mat

func set_select(val:bool):
	$border.visible = val
