@tool
class_name RoofComponent
extends Node2D

@export var occlusion_time: float = 0.5
@export var occlusion_color: Color = Color(1, 1, 1, 0)

@onready var roof_tilemap: TileMapLayer = $"Roof Tilemap"

var original_color: Color = Color(1, 1, 1, 1)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		Global.player_house_entered = true
		AudioManager.play_sfx_at_location(body.global_position, SoundResource.SoundType.PLAYER_ENTER_HOUSE)
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(roof_tilemap, "modulate", occlusion_color, occlusion_time)
	elif body == Global.ghost_node:
		print("Ghost in house")
		await get_tree().create_timer(randf_range(3, 5)).timeout
		AudioManager.play_sfx_at_location(body.global_position, SoundResource.SoundType.PLAYER_ENTER_HOUSE)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		Global.player_house_entered = false
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(roof_tilemap, "modulate", original_color, occlusion_time)
