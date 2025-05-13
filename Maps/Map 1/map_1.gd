class_name Map
extends Node2D

@export var spawner_component: SpawnerComponent

func _ready() -> void:
	spawner_component.point_spawn()
