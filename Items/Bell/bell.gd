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
	
	if display_item:
		var seconds = int(timer.time_left) % 60
		bell_timer_lable.text = str("%02d" % seconds)

func _on_bell_rang(_volume: float):
	if not timer.is_stopped():
		SignalBus.bell_on_cooldown.emit()
		return
	elif timer.is_stopped() and ghost_detection_component.ghost_detected:
		timer.start()
	if display_item and not Global.bell_equipped:
		return
	bell_rang = true
	if not display_item:
		animation_player.play("ring")
	_update_item_response()
	await animation_player.animation_finished
	bell_rang = false

func _update_bell_audio() -> void:
	for ring in range(0, randi_range(3,5)):
		AudioManager.play_sfx_at_location(Global.player_position, SoundResource.SoundType.ITEM_BELL_RING)
		await get_tree().create_timer(randf_range(0.15, 0.3)).timeout

func _update_item_response() -> void:
	if ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.GhostNames.YUKIONNA:
		_update_bell_audio()
		#print("Yuki Detected", ", *No Ring*")
	elif ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.GhostNames.ONRYO:
		_update_bell_audio()
		#print("Onryo Detected", ", *Muted Ring*")
	elif ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.GhostNames.JIKININKI:
		_update_bell_audio()
		#print("Jikininki Detected", ", *Muted Ring*")
	elif ghost_detection_component.ghost_detected and not bell_rang:
		pass
		#print("Not ringing")
	elif not ghost_detection_component.ghost_detected:
		pass
		#print("Ghost not detected")
