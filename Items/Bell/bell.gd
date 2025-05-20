extends Node2D

@export var ghost_detection_component: GhostDetectionComponent
@export var display_item: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

var bell_rang: bool = false
#var bell_timer_lable: Label
var bell_ring_played: bool = false

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
	
	if not timer.is_stopped():
		var seconds = int(timer.time_left) % 60
		Global.bell_cooldown_label.text = str("%02d" % seconds)

func _on_bell_rang(_volume: float):
	if not timer.is_stopped():
		SignalBus.bell_on_cooldown.emit()
		return
	if display_item and not Global.bell_equipped:
		return
	bell_rang = true
	if not display_item and Global.bell_equipped:
		animation_player.play("ring")
	_update_item_response()
	#await animation_player.animation_finished
	bell_rang = false

func _update_bell_audio(type: int = 0) -> void:
	if type == 0:
		for ring in range(0, randi_range(3,5)):
			AudioManager.play_sfx_at_location(Global.player_position, SoundResource.SoundType.ITEM_BELL_RING)
			await get_tree().create_timer(randf_range(0.15, 0.3)).timeout
	elif type == 1 and not bell_ring_played:
		AudioManager.play_sfx_at_location(Global.player_position, SoundResource.SoundType.ITEM_BELL_RING_2)
		bell_ring_played = true
		await get_tree().create_timer(4).timeout
		bell_ring_played = false

func _update_item_response() -> void:
	if not ghost_detection_component.ghost_detected or (ghost_detection_component.ghost_detected and not bell_rang):
		return
	elif ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.GhostNames.YUKIONNA:
		if randf_range(0, 1) <= 0.75:
			_update_bell_audio(1)
			timer.start()
	elif ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.GhostNames.ONRYO:
		if randf_range(0, 1) <= 0.75:
			_update_bell_audio(0)
			timer.start()
	elif ghost_detection_component.ghost_detected and bell_rang and ghost_detection_component.ghost_type == Global.GhostNames.JIKININKI:
		if randf_range(0, 1) <= 0.75:
			_update_bell_audio(randi_range(0, 1))
			timer.start()
