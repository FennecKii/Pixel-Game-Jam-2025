extends Node2D

func _on_pressed_play():
	get_tree().change_scene_to_file("res://UI/map_select.tscn")

func _on_pressed_quit():
	get_tree().quit()
