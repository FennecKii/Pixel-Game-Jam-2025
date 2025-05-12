class_name SpawnerComponent
extends Node2D

@export var points: Array[Marker2D]

@onready var root_node: Node2D = get_tree().get_root().get_node("Map")

func point_spawn():
	var spawn_point: Marker2D = points.pick_random()
	var ghost: PackedScene = Global.ghost_scene_array.pick_random()
	var ghost_instance = ghost.instantiate()
	ghost_instance.global_position = spawn_point.global_position
	#ghost_instance.visible = false
	root_node.add_child(ghost_instance)
