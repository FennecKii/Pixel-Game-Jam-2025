extends Node2D

func _ready():
	$FadeRect/AnimationPlayer.play("fade_in")

func _on_play_again_pressed():
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS)
	get_tree().change_scene_to_file("res://UI/map_select.tscn")

func _on_main_menu_pressed():
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS)
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_button_mouse_entered() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_HOVER)
