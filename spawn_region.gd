@tool
class_name SpawnerRect2D
extends Node2D

@export var outline_color: Color = Color("#cd5c5c82")
@export_range(0, 30, 0.5) var outline_width: float = 2.5
@export var filled: bool = true
@export var rect_size: Vector2 = Vector2(100, 100)
@export var runtime_render: bool = false

var rect_region: Rect2

func _ready() -> void:
	if runtime_render:
		process_mode = Node.PROCESS_MODE_DISABLED
	rect_region.position = Vector2.ZERO

func _process(delta: float) -> void:
	rect_region.size = rect_size
	queue_redraw()
	if rect_region.has_point(get_global_mouse_position()):
		EditorInterface.edit_node(self)
		EditorSelection.new()

func _draw() -> void:
	draw_rect(rect_region, outline_color, filled, outline_width)
