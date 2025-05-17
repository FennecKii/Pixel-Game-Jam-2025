class_name TimerComponent
extends Node2D

@export_range(0, 240, 1.0) var duration: float = 120

@onready var timer: Timer = $Timer
@onready var time_remaining: Label = %"Time Remaining"
@onready var times_up: Label = %"Times Up"

func _ready() -> void:
	timer.wait_time = duration
	timer.start()

func _process(_delta: float) -> void:
	var minutes = int(timer.time_left) / 60
	var seconds = int(timer.time_left) % 60
	time_remaining.text = str("%01d:%02d" % [minutes, seconds])
	
	if timer.is_stopped():
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(times_up, "self_modulate", Color(1, 1, 1, 1), 0.5)
		tween.tween_property(times_up, "modulate", Color(0.882, 0.384, 0.322, 0.0), 0.5)
		SignalBus.ghost_alerted.emit()
		
