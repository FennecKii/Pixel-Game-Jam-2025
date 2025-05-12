extends Node2D

@onready var compass_base: Sprite2D = $"Compass Base"
@onready var compass_needle: Sprite2D = $"Compass Needle"

var random_direction: Vector2
var compass_malfunction: bool = false

func _process(delta: float) -> void:
	if not Global.ghost_detected:
		random_direction = global_position + Vector2.from_angle(deg_to_rad(randf_range(0, 360)))
		compass_needle.look_at(random_direction)
	elif Global.ghost_detected:
		compass_needle.look_at((Global.ghost_direction - Global.player_position).normalized())
