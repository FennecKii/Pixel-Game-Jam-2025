class_name SpawnerComponent
extends Node2D

@export var spawn_regions: Array[SpawnerRect2D]

@onready var root_node: Node2D = get_tree().get_root().get_node("Map")

func point_spawn():
	var spawn_point: SpawnerRect2D = spawn_regions.pick_random()
	var ghost: PackedScene = Global.ghost_scene_array.pick_random()
	var ghost_instance = ghost.instantiate()
	var position_variation: Vector2 = Vector2(randf_range(0, spawn_point.size), randf_range(0, spawn_point.size))
	ghost_instance.global_position = spawn_point.global_position + position_variation
	#ghost_instance.visible = false
	if root_node != null:
		root_node.add_child(ghost_instance)
