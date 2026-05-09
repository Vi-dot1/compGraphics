extends Camera3D

@export var cam_speed:float = 2.2
var dir:Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position.x += dir.x*delta*cam_speed
	position.z += dir.y*delta*cam_speed

func _unhandled_input(_event: InputEvent) -> void:
	dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
