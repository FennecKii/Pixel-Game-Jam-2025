@tool
class_name SpawnerRect2D
extends Node2D

@export var outline_color: Color = Color("#cd5c5c82")
@export_range(0, 30, 0.5) var outline_width: float = 2.5
@export var filled: bool = true
@export var rect_size: Vector2 = Vector2(100, 100)
@export var runtime_render: bool = false

var rect_region: Rect2

func _enter_tree() -> void:
	add_to_group("spawn regions")

func _ready() -> void:
	if not (Engine.is_editor_hint() or runtime_render):
		process_mode = Node.PROCESS_MODE_DISABLED
	rect_region.position = Vector2.ZERO

func _process(delta: float) -> void:
	rect_region.size = rect_size
	queue_redraw()

func _draw() -> void:
	if filled:
		draw_rect(rect_region, outline_color, filled)
	else:
		draw_rect(rect_region, outline_color, filled, outline_width)
