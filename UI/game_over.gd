extends Node2D

func _on_pressed_play_again():
	get_tree().change_scene_to_file("res://Maps/Map 1/map_1.tscn")
	
func _on_pressed_quit():
	get_tree().quit()
