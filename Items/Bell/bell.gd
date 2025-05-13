extends Node2D

@export var display_item: bool = false

@onready var bell_rang_label: Label = $"Bell Rang"

func _ready() -> void:
	SignalBus.bell_rang.connect(_on_bell_rang)

func _on_bell_rang(volume: float):
	if display_item:
		return
	bell_rang_label.visible = true
	await get_tree().create_timer(1).timeout
	bell_rang_label.visible = false
