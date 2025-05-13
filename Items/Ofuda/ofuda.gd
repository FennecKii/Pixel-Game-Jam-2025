extends Node2D

@export var ofuda_placed: bool = false

@onready var ofuda_placed_label: Label = $"Ofuda Placed"

var ofuda_count: int = 0

func _ready() -> void:
	SignalBus.ofuda_placed.connect(_on_ofuda_place)

func _on_ofuda_place(count: int):
	ofuda_count = count
	ofuda_placed_label.visible = true
	await get_tree().create_timer(1).timeout
	ofuda_placed_label.visible = false
