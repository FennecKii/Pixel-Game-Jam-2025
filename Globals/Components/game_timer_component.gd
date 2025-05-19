class_name TimerComponent
extends Node2D


const max_game_time: float = 300

@export_range(0, max_game_time, 1.0) var duration: float = 120
@export_range(0, max_game_time, 1.0) var alert_time: float = 30

@onready var timer: Timer = $Timer
@onready var time_remaining: Label = %"Time Remaining"
@onready var times_up: Label = %"Times Up"
@onready var timer_tick_audio: AudioStreamPlayer = $"Timer Tick Audio"

var timer_tick_played: bool = false
var stop_sequence: bool = false

func _ready() -> void:
	timer.wait_time = duration
	timer.start()
	timer_tick_audio.stream.loop = true

func _process(_delta: float) -> void:
	var minutes = int(timer.time_left) / 60
	var seconds = int(timer.time_left) % 60
	time_remaining.text = str("%01d:%02d" % [minutes, seconds])
	
	if abs(timer.time_left - alert_time - 1) < 0.01:
		AudioManager.play_sfx_global(SoundResource.SoundType.GAME_TIMER_ALERT)
	
	if timer.time_left < alert_time + 1 and timer.time_left > 0 and not timer_tick_played:
		timer_tick_audio.play()
		timer_tick_played = true
	
	if timer.is_stopped() and timer_tick_played:
		timer_tick_audio.stop()
		timer_tick_played = false
	
	if timer.time_left <= 1 and not stop_sequence:
		stop_sequence = true
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(times_up, "self_modulate", Color(1, 1, 1, 1), 0.75)
		AudioManager.play_sfx_global(SoundResource.SoundType.GAME_TIMER_END)
		tween.tween_property(times_up, "self_modulate", Color(1, 1, 1, 0), 0.75)
		AudioManager.lower_audio()
		await get_tree().create_timer(0.25).timeout
		AudioManager.lower_audio()
		await get_tree().create_timer(0.25).timeout
		AudioManager.lower_audio()
		await get_tree().create_timer(0.25).timeout
		AudioManager.lower_audio()
		SignalBus.ghost_alerted.emit()
		
