class_name SpawnerComponent
extends Node2D

@export var spawn_regions: Array[SpawnerRect2D]
@export var world_objects: Node2D

@onready var spawn_regions_group: Array[Node] = get_tree().get_nodes_in_group("spawn regions")

func _ready() -> void:
	if spawn_regions.is_empty() or len(spawn_regions_group) != len(spawn_regions):
		spawn_regions = []
		for spawn_region in spawn_regions_group:
			spawn_regions.append(spawn_region)
	Global.spawn_regions = spawn_regions

func spawn_ghost():
	if spawn_regions.is_empty():
		assert(false, "No spawn regions found.")
	var spawn_region: SpawnerRect2D = spawn_regions.pick_random()
	var ghost_type: int = randi_range(0, len(Global.GhostNames) - 1)
	var ghost_appearance: int = randi_range(0, len(Global.GhostAppearance) - 1)
	var ghost_instance = Global.ghost_scene.instantiate()
	var position_variation: Vector2 = Vector2(randf_range(0, spawn_region.rect_size.x), randf_range(0, spawn_region.rect_size.y))
	Global.current_ghost = ghost_type
	Global.ghost_appearance = ghost_appearance
	ghost_instance.global_position = spawn_region.global_position + position_variation
	ghost_instance.ghost_type = ghost_type
	ghost_instance.visible = false
	ghost_instance.ghost_appearance = ghost_appearance
	if Global.world_objects_node:
		Global.world_objects_node.add_child(ghost_instance)
	elif world_objects:
		world_objects.add_child(ghost_instance)
	elif Global.world_node:
		Global.world_node.add_child(ghost_instance)

func spawn_mirror() -> void:
	var spawn_region: SpawnerRect2D = spawn_regions.pick_random()
	var mirror_instance = Global.mirror_scene.instantiate()
	var rand_wall: int = randi_range(0, 2)
	mirror_instance.mirror_type = rand_wall
	mirror_instance.scale = Vector2(3, 3)
	if rand_wall == 0:
		mirror_instance.global_position = spawn_region.global_position + Vector2(spawn_region.rect_size.x/2, 20)
	elif rand_wall == 1:
		mirror_instance.global_position = spawn_region.global_position + Vector2(spawn_region.rect_size.x - 20, spawn_region.rect_size.y/2)
	elif rand_wall == 2:
		mirror_instance.global_position = spawn_region.global_position + Vector2(20, spawn_region.rect_size.y/2)
	if Global.world_objects_node:
		Global.world_objects_node.add_child(mirror_instance)
	elif world_objects:
		world_objects.add_child(mirror_instance)
	elif Global.world_node:
		Global.world_node.add_child(mirror_instance)
