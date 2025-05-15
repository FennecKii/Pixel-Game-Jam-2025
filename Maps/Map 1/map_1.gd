class_name Map
extends Node2D

@export var spawner_component: SpawnerComponent
@export var world_objects_node: Node2D
@export var book_ui: CanvasLayer

func _ready() -> void:
	Global.world_node = self
	if world_objects_node:
		Global.world_objects_node = world_objects_node
	else:
		world_objects_node = Node2D.new().instantiate()
		world_objects_node.y_sort_enabled = true
		Global.world_objects_node = world_objects_node
		add_child(world_objects_node)
	spawner_component.point_spawn()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_journal") and book_ui:
		book_ui.visible = !book_ui.visible
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if book_ui.visible else Input.MOUSE_MODE_CAPTURED)
	elif Input.is_action_just_pressed("toggle_journal") and not book_ui:
		assert(false, "Book UI CanvasLayer not found in root node.")
