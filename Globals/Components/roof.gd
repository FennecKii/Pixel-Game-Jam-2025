@tool
class_name RoofComponent
extends Node2D

@export var occlusion_time: float = 0.5
@export var occlusion_color: Color = Color(1, 1, 1, 0.5)

@onready var roof_tilemap: TileMapLayer = $"Roof Tilemap"

var original_color: Color = Color(1, 1, 1, 1)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(roof_tilemap, "modulate", occlusion_color, occlusion_time)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(roof_tilemap, "modulate", original_color, occlusion_time)
