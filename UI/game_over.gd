extends Node2D

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	AudioManager.play_sfx_global(randi_range(SoundResource.SoundType.AMBIENT_KNOCK_1, SoundResource.SoundType.AMBIENT_HEX))

func _on_pressed_play_again() -> void:
	get_tree().change_scene_to_file("res://UI/map_select.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
