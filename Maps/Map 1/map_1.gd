class_name Map
extends Node2D

@export var spawner_component: SpawnerComponent
@export var roof_tilemap: TileMapLayer

@onready var book_ui = $CanvasLayer

var occlude_tiles: bool = false

func _ready() -> void:
	spawner_component.point_spawn()

func _process(_delta):
	if Input.is_action_just_pressed("toggle_journal"):
		book_ui.visible = !book_ui.visible
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if book_ui.visible else Input.MOUSE_MODE_CAPTURED)
	
	#if occlude_tiles:
	#	_modulate_tiles(0.5)
	#elif not occlude_tiles:
	#	_modulate_tiles(1)

func _modulate_tiles(alpha: float) -> void:
	var roof_position: Vector2 = roof_tilemap.to_local(Global.player_position)
	var roof_cell: Vector2i = roof_tilemap.local_to_map(roof_position)
	var celldata: TileData = roof_tilemap.get_cell_tile_data(roof_cell)
	
	if celldata:
		celldata.modulate.a = alpha
		SignalBus.tile_occulsion.emit(roof_cell, celldata)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		_modulate_tiles(0.5)
		occlude_tiles = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		occlude_tiles = false
