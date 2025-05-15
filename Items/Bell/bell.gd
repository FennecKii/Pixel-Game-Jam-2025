extends Node2D

@export var ghost_detection_component: GhostDetectionComponent
@export var display_item: bool = false

@onready var bell_rang_label: Label = $"Bell Rang"

var bell_rang: bool = false

func _ready() -> void:
	if not ghost_detection_component:
		assert(false, "Ghost Detection Component not found.")
	
	SignalBus.bell_rang.connect(_on_bell_rang)
	if display_item and not Global.bell_equipped:
		ghost_detection_component.process_mode = Node.PROCESS_MODE_DISABLED
		ghost_detection_component.visible = false
		ghost_detection_component.collision.visible = false

func _process(_delta: float) -> void:
	if not display_item and Global.bell_equipped:
		ghost_detection_component.process_mode = Node.PROCESS_MODE_INHERIT
		ghost_detection_component.visible = true
		ghost_detection_component.collision.visible = true
		_update_item_response()

func _on_bell_rang(_volume: float):
	if display_item:
		return
	bell_rang_label.visible = true
	bell_rang = true
	await get_tree().create_timer(1).timeout
	bell_rang_label.visible = false
	bell_rang = false

func _update_item_response() -> void:
	if ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.yuki_onna_node:
		print("Yuki Detected", ", *Muted Ring*")
	elif ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.onryo_node:
		print("Onryo Detected", ", *Muted Ring*")
	elif ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.jikininki_node:
		print("Jikininki Detected", ", *No Ring*")
	elif ghost_detection_component.ghost_detected and not bell_rang:
		print("Not ringing")
	elif not ghost_detection_component.ghost_detected:
		print("Ghost not detected")
