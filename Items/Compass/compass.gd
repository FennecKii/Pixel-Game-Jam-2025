extends Node2D

@onready var compass_base: Sprite2D = $"Compass Base"
@onready var compass_needle: Sprite2D = $"Compass Needle"

var compass_malfunction: bool = false
var tracking: bool = false
var ghost_direction: Vector2
var random_direction: Vector2
var new_direction: Vector2
var random_angle: float
var tracking_speed: float

func _process(delta: float) -> void:
	if not Global.ghost_detected:
		random_angle = deg_to_rad(randf_range(0, 360))
		random_direction = global_position.rotated(random_angle)
		compass_needle.look_at(random_direction)
	elif Global.ghost_detected:
		_smooth_tracking(delta)
		# Lagged tracking
		#if not tracking:
		#	_smooth_tracking(delta, 1.75, 140)
		#	tracking = true
		#	await get_tree().create_timer(0.075).timeout
		#	tracking = false

func _smooth_tracking(delta_time: float, tracking_speed: float = 4.5, angle_deviation: float = 115):
	ghost_direction = (Global.ghost_position - Global.player_position).normalized()
	random_angle = deg_to_rad(randf_range(-angle_deviation, angle_deviation))
	random_direction = ghost_direction.rotated(random_angle)
	new_direction = new_direction.lerp(random_direction, delta_time * tracking_speed)
	compass_needle.look_at(global_position + new_direction)

func _noisy_tracking(angle_deviation: float = 35):
	ghost_direction = (Global.ghost_position - Global.player_position).normalized()
	random_angle = deg_to_rad(randf_range(-angle_deviation, angle_deviation))
	random_direction = ghost_direction.rotated(random_angle)
	compass_needle.look_at(global_position + random_direction)

func _perfect_tracking():
	ghost_direction = (Global.ghost_position - Global.player_position).normalized()
	compass_needle.look_at(global_position + ghost_direction)
