extends Node

signal bell_rang(volume: float)
signal ofuda_placed()
signal ofuda_pickedup()
signal ofuda_count_changed(count: int)
signal tile_occulsion(cell: Vector2i, celldata: TileData)
