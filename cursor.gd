extends Area3D
class_name Cursor

@export var place_color: Color = Color(0, 1, 0, 0.5)
@export var block_color: Color = Color(1, 0, 0, 0.5)

@onready var visual_root = $Node3D
var current_piece_visual: DominoPiece = null
var free: bool = true
var rotation_index: int = 0

func _ready() -> void:
	for child in visual_root.get_children():
		child.queue_free()

func set_piece(data: Gameplay.DominoData):
	if current_piece_visual:
		current_piece_visual.queue_free()
		current_piece_visual = null

	if data == null:
		return

	var scene = load("res://domino_piece.tscn")
	current_piece_visual = scene.instantiate()
	visual_root.add_child(current_piece_visual)
	current_piece_visual.setup(data)
	# Disable collision on cursor preview
	current_piece_visual.process_mode = Node.PROCESS_MODE_DISABLED

func rotate_piece():
	rotation_index = (rotation_index + 1) % 4
	visual_root.rotation_degrees.y = rotation_index * 90
