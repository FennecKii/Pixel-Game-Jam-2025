class_name Map
extends Node2D

@export var spawner_component: SpawnerComponent
@export var world_objects_node: Node2D
@export var world_boundaries: Array[SpawnerRect2D]
@export var book_ui: CanvasLayer

@onready var world_boundaries_group: Array[Node] = get_tree().get_nodes_in_group("world regions")

func _ready() -> void:	
	Global.scene_tree = get_tree()
	
	if world_boundaries.is_empty() or len(world_boundaries_group) != len(world_boundaries):
		world_boundaries = []
		for world_region in world_boundaries_group:
			world_boundaries.append(world_region)
		Global.world_boundaries = world_boundaries
	
	if world_boundaries.is_empty():
		assert(false, "World boundaries array not found in root node.")
	
	Global.world_node = self
	SignalBus.player_dead.connect(_on_player_dead)
	if world_objects_node:
		Global.world_objects_node = world_objects_node
	else:
		world_objects_node = Node2D.new().instantiate()
		world_objects_node.y_sort_enabled = true
		Global.world_objects_node = world_objects_node
		add_child(world_objects_node)
	spawner_component.spawn_ghost()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_journal") and book_ui:
		book_ui.visible = !book_ui.visible
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if book_ui.visible else Input.MOUSE_MODE_CAPTURED)
	elif Input.is_action_just_pressed("toggle_journal") and not book_ui:
		assert(false, "Book UI CanvasLayer not found in root node.")

func _on_player_dead() -> void:
	Global.scene_tree.change_scene_to_file("res://UI/main_menu.tscn")
