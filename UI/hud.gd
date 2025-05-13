extends Control

@onready var compass: Node2D = $Compass
@onready var screen_size: Vector2 = get_viewport_rect().size

func _ready() -> void:
	compass.position = Vector2(screen_size.x/2, screen_size.y - 50)
