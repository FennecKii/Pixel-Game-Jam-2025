extends Node2D

@export var display_item: bool = false
@export var held_item: bool = false

@onready var pickup_area: Area2D = $"Pickup Area"
@onready var pickup_collision: CollisionShape2D = $"Pickup Area/Pickup Collision"
@onready var ofuda_placed_label: Label = $"Ofuda Placed"
@onready var pickup_label: Label = $Pickup

var ofuda_placed: bool = false
var can_pickup: bool = false
var ofuda_count_lable: Label
var ofuda_count: int = 0

func _ready() -> void:
	SignalBus.ofuda_placed.connect(_on_ofuda_placed)
	SignalBus.ofuda_count_changed.connect(_on_ofuda_count_changed)
	if display_item:
		ofuda_count_lable = $Labels/Value
	
	if not ofuda_placed or not display_item:
		pickup_area.process_mode = Node.PROCESS_MODE_DISABLED
		pickup_collision.visible = false

func _process(_delta: float) -> void:
	_update_ofuda_label()
	
	_ofuda_pickup()
	
	if ofuda_count != 0 and not display_item:
		ofuda_placed = true
	
	if ofuda_placed and not display_item:
		pickup_area.process_mode = Node.PROCESS_MODE_INHERIT
		pickup_collision.visible = true
	
	if can_pickup:
		pickup_label.visible = true
	else:
		pickup_label.visible = false

func _update_ofuda_label() -> void:
	if ofuda_count_lable != null:
		ofuda_count_lable.text = str(2-ofuda_count)
		ofuda_count_lable.add_theme_color_override("font_color", Color.LIME_GREEN) 
	if ofuda_count_lable != null and ofuda_count == 2:
		ofuda_count_lable.add_theme_color_override("font_color", Color.RED) 

func _on_ofuda_placed() -> void:
	if display_item:
		return
	
	if ofuda_placed or held_item:
		return
	
	ofuda_placed_label.visible = true
	await get_tree().create_timer(1).timeout
	ofuda_placed_label.visible = false

func _on_ofuda_count_changed(count: int) -> void:
	if display_item:
		ofuda_count = count

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		can_pickup = true

func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		can_pickup = false

func _ofuda_pickup() -> void:
	if can_pickup and Input.is_action_just_pressed("Interact"):
		SignalBus.ofuda_pickedup.emit()
		queue_free()
