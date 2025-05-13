extends Node2D

@export var display_item: bool = false
@export var ofuda_placed: bool = false

@onready var ofuda_placed_label: Label = $"Ofuda Placed"

var ofuda_count_lable: Label
var ofuda_count: int = 0

func _ready() -> void:
	SignalBus.ofuda_placed.connect(_on_ofuda_place)
	if display_item:
		ofuda_count_lable = $Labels/Value

func _on_ofuda_place(count: int):
	ofuda_count = count
	if ofuda_count_lable != null:
		ofuda_count_lable.text = str(2-ofuda_count)
	if ofuda_count_lable != null and ofuda_count == 2:
		ofuda_count_lable.add_theme_color_override("font_color", Color.RED) 
	if display_item:
		return
	ofuda_placed_label.visible = true
	await get_tree().create_timer(1).timeout
	ofuda_placed_label.visible = false
