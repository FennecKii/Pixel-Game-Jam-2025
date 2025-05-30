extends Node2D

@onready var compass_base: Sprite2D = $"Compass Base"
@onready var compass_needle: Sprite2D = $"Compass Needle"

var compass_malfunction: bool = false
var tracking: bool = false
var ghost_direction: Vector2
var random_direction: Vector2
var new_direction: Vector2
var random_angle: float

func _process(delta: float) -> void:
	if not Global.ghost_detectable:
		_noisy_tracking(180)
	elif Global.ghost_detectable and not Global.player_ghost_detected:
		_noisy_tracking(50)
	elif Global.ghost_detectable and Global.player_ghost_detected:
		#_noisy_tracking()
		# Lagged tracking
		#if not tracking: # Condition for greater lag
			_lagged_tracking(delta)

func _smooth_tracking(delta_time: float, tracking_speed: float = 4.5, angle_deviation: float = 115):
	ghost_direction = (Global.ghost_position - Global.player_position).normalized()
	random_angle = deg_to_rad(randf_range(-angle_deviation, angle_deviation))
	random_direction = ghost_direction.rotated(random_angle)
	new_direction = new_direction.lerp(random_direction, delta_time * tracking_speed)
	compass_needle.look_at(global_position + new_direction)

func _lagged_tracking(delta_time: float, tracking_speed: float = 1.75, angle_deviation: float = 135):
	_smooth_tracking(delta_time, tracking_speed, angle_deviation)
	tracking = true
	await get_tree().create_timer(0.075).timeout
	tracking = false

func _noisy_tracking(angle_deviation: float = 45):
	ghost_direction = (Global.ghost_position - Global.player_position).normalized()
	random_angle = deg_to_rad(randf_range(-angle_deviation, angle_deviation))
	random_direction = ghost_direction.rotated(random_angle)
	compass_needle.look_at(global_position + random_direction)

func _perfect_tracking():
	ghost_direction = (Global.ghost_position - Global.player_position).normalized()
	compass_needle.look_at(global_position + ghost_direction)
