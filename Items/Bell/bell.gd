extends Node2D

@export var ghost_detection_component: GhostDetectionComponent
@export var display_item: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

var bell_rang: bool = false
var bell_timer_lable: Label

func _ready() -> void:
	if not ghost_detection_component:
		assert(false, "Ghost Detection Component not found.")
	
	if display_item:
		bell_timer_lable = $Labels/Value
	
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
	
	if display_item:
		var seconds = int(timer.time_left) % 60
		bell_timer_lable.text = str("%02d" % seconds)

func _on_bell_rang(_volume: float):
	if not timer.is_stopped():
		SignalBus.bell_on_cooldown.emit()
		return
	elif timer.is_stopped():
		timer.start()
	if display_item:
		return
	bell_rang = true
	animation_player.play("ring")
	await animation_player.animation_finished
	bell_rang = false

func _update_item_response() -> void:
	if ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.yuki_onna_node:
		pass
		#print("Yuki Detected", ", *No Ring*")
	elif ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.onryo_node:
		pass
		#print("Onryo Detected", ", *Muted Ring*")
	elif ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.jikininki_node:
		pass
		#print("Jikininki Detected", ", *Muted Ring*")
	elif ghost_detection_component.ghost_detected and not bell_rang:
		pass
		#print("Not ringing")
	elif not ghost_detection_component.ghost_detected:
		pass
		#print("Ghost not detected")
