extends Node2D

func _on_map1_pressed():
	get_tree().change_scene_to_file("res://Maps/Map 1/map_1.tscn")

func _on_map_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Maps/Map2/map2.tscn")
