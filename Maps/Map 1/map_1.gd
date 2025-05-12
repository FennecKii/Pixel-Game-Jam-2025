extends Node2D

@onready var spawner_component: SpawnerComponent = $SpawnerComponent

func _ready() -> void:
	spawner_component.point_spawn()
