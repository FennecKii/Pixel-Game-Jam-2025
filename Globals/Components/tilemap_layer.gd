extends TileMapLayer

func _ready() -> void:
	SignalBus.tile_occulsion.emit(_on_tile_occulsion)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	pass

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return true

func _on_tile_occulsion(cell: Vector2i, celldata: TileData) -> void:
	_tile_data_runtime_update(cell, celldata)
