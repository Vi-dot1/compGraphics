extends Control

@onready var flash:CheckBox = $PanelOpciones/MarginContainer/VBoxContainer/flash/val
@onready var num_juadores = $PanelOpciones/MarginContainer/VBoxContainer/jugadores/val
@onready var pase_recarga:CheckBox = $PanelOpciones/MarginContainer/VBoxContainer/paseRecarga/val
@onready var recarga:CheckBox = $PanelOpciones/MarginContainer/VBoxContainer/recarga/val
@onready var mapa:ItemList = $PanelOpciones/MarginContainer/VBoxContainer/mapa/val

@onready var rule_recarga:RichTextLabel = $PanelReglas/MarginContainer/VBoxContainer/cargaLibre
@onready var rule_pase_recarga:RichTextLabel = $PanelReglas/MarginContainer/VBoxContainer/cargaPasa
@onready var rule_flash:RichTextLabel = $PanelReglas/MarginContainer/VBoxContainer/flash

func _ready() -> void:
	_on_flash(Gameplay.flash)
	_on_pase_recarga(Gameplay.draw_after_pass)
	_on_recarga(Gameplay.can_draw)
	
	num_juadores.value = Gameplay.player_amnt
	
	
	mapa.item_selected.connect(_on_map_selected)
	flash.toggled.connect(_on_flash)
	pase_recarga.toggled.connect(_on_pase_recarga)
	recarga.toggled.connect(_on_recarga)
	num_juadores.value_changed.connect(_on_num_jugadores)

func _on_map_selected(idx:int) -> void:
	Global.entorno = idx

func _on_recarga(val:bool) -> void:
	Gameplay.can_draw = val
	rule_recarga.visible = val
	recarga.button_pressed = val
func _on_pase_recarga(val:bool) -> void:
	Gameplay.draw_after_pass = val
	rule_pase_recarga.visible = val
	pase_recarga.button_pressed = val
func _on_flash(val:bool) -> void:
	Gameplay.flash = val
	rule_flash.visible = val
	flash.button_pressed = val

func _on_num_jugadores(val: int) -> void:
	Gameplay.player_amnt = val
