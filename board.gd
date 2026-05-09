extends Node3D

var dir:Vector2
@export var rotation_speed:float = 2.4

func _physics_process(delta: float) -> void:
	rotate_x(dir.x*rotation_speed*delta)
	rotate_z(dir.y*rotation_speed*delta)

func _unhandled_input(_event: InputEvent) -> void:
	dir = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	
