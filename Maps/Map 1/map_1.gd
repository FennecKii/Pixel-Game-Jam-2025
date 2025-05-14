class_name Map
extends Node2D

@export var spawner_component: SpawnerComponent

@onready var book_ui = $CanvasLayer

func _ready() -> void:
	spawner_component.point_spawn()

func _process(_delta):
	if Input.is_action_just_pressed("toggle_journal"):
		book_ui.visible = !book_ui.visible
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if book_ui.visible else Input.MOUSE_MODE_CAPTURED)
