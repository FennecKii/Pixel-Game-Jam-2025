extends Node2D

func _on_pressed_play_again() -> void:
	get_tree().change_scene_to_file("res://UI/map_select.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
