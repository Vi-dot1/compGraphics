extends Node3D

@onready var cam = $camMount/Camera3D
@onready var cursor:Cursor = $cursor
@onready var plane = $plane

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _physics_process(_delta: float) -> void:
	cursor.position = to_global(cam.project_position(get_viewport().get_mouse_position(), cam.position.y))
	
	
	cursor.position = plane.to_global(cursor.position)
	
	
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("place") and cursor.free and $plane.can_place:
		plane._place(Vector2(cursor.position.x, cursor.position.z))
