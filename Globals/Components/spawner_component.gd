class_name SpawnerComponent
extends Node2D

@export var spawn_regions: Array[SpawnerRect2D]

@onready var root_node: Node2D = get_tree().get_root().get_node("Map")
@onready var spawn_regions_group: Array[Node] = get_tree().get_nodes_in_group("spawn regions")

func _ready() -> void:
	if spawn_regions.is_empty() or len(spawn_regions_group) != len(spawn_regions):
		spawn_regions = []
		for spawn_region in spawn_regions_group:
			spawn_regions.append(spawn_region)

func point_spawn():
	if spawn_regions.is_empty():
		push_warning("No spawn regions found...")
		return
	var spawn_region: SpawnerRect2D = spawn_regions.pick_random()
	var ghost: PackedScene = Global.ghost_scene_array.pick_random()
	var ghost_instance = ghost.instantiate()
	var position_variation: Vector2 = Vector2(randf_range(0, spawn_region.rect_size.x), randf_range(0, spawn_region.rect_size.y))
	ghost_instance.global_position = spawn_region.global_position + position_variation
	#ghost_instance.visible = false
	if root_node != null:
		root_node.add_child(ghost_instance)
