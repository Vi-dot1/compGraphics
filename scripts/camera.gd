extends Node3D

@export var cam_speed:float = 4.5
@onready var cam = $Camera3D

var blocked:bool = true

var cam_distance:float = 20 :
	set(val):
		cam_distance = val
		cam.position.z = val

var dir:Vector2 = Vector2.ZERO
var shake_amount: float = 0.0

var target_pos: Vector3
var target_height: float = 6.0

func _ready():
	target_pos = position
	target_height = position.y

func _physics_process(delta: float) -> void:
	rotate_object_local(Vector3(1,0,0), dir.y*(cam_speed/Global.planet_radius)*delta)
	rotate_object_local(Vector3(0,1,0), dir.x*(cam_speed/Global.planet_radius)*delta)
	
	if shake_amount > 0:
		cam.h_offset = randf_range(-shake_amount, shake_amount)
		cam.v_offset = randf_range(-shake_amount, shake_amount)
		shake_amount = lerp(shake_amount, 0.0, delta * 10.0)
	else:
		cam.h_offset = 0
		cam.v_offset = 0

func rot_to(to:Vector3) -> void:
	if blocked: 
		return
	
	rotation_degrees = Vector3.ZERO
	
	var from = cam.position.normalized()
	to = to_local(to).normalized()
	
	var cross = from.cross(to)
	var angle:float = from.angle_to(to)
	var axis = cross / cross.length()
	
	var rot:Vector3 = Quaternion(axis, angle).get_euler()
	
	var t:Tween = get_tree().create_tween()
	
	blocked = true
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_LINEAR)
	t.tween_property(self, "rotation", rotation+rot, 0.1)
	t.tween_property(self, "dir", Vector2.ZERO, 0.01)
	t.tween_property(self, "blocked", false, 0.3)
	

func shake(amount: float = 0.2):
	shake_amount = amount

func focus_on(center: Vector3, max_dim: float):
	target_pos = center
	# Only increase height if the current height is not enough to cover the board
	var required_height = max(6.0, max_dim * 1.5)
	if required_height > target_height:
		target_height = required_height

func _unhandled_input(_event: InputEvent) -> void:
	if blocked: 
		return
	dir = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
