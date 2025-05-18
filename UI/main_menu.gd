extends Node2D

func _ready() -> void:
	AudioManager.play_music_background(MusicResource.MusicType.BACKGROUND_AMBIENCE_TRACK_1)

func _on_pressed_play():
	get_tree().change_scene_to_file("res://UI/map_select.tscn")

func _on_pressed_quit():
	get_tree().quit()
	
