extends Camera3D

@export var cam_speed:float = 2.2
var dir:Vector2 = Vector2.ZERO
var shake_amount: float = 0.0

var target_pos: Vector3
var target_height: float = 6.0

func _ready():
	target_pos = position
	target_height = position.y

func _physics_process(delta: float) -> void:
	# Manual movement
	target_pos.x += dir.x*delta*cam_speed
	target_pos.z += dir.y*delta*cam_speed
	
	# Smooth follow
	position = position.lerp(Vector3(target_pos.x, target_height, target_pos.z), delta * 5.0)
	
	if shake_amount > 0:
		h_offset = randf_range(-shake_amount, shake_amount)
		v_offset = randf_range(-shake_amount, shake_amount)
		shake_amount = lerp(shake_amount, 0.0, delta * 10.0)
	else:
		h_offset = 0
		v_offset = 0

func shake(amount: float = 0.2):
	shake_amount = amount

func focus_on(center: Vector3, max_dim: float):
	target_pos = center
	# Only increase height if the current height is not enough to cover the board
	var required_height = max(6.0, max_dim * 1.5)
	if required_height > target_height:
		target_height = required_height

func _unhandled_input(_event: InputEvent) -> void:
	dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
