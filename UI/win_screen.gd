extends Node2D

func _ready():
	$FadeRect/AnimationPlayer.play("fade_in")
	AudioManager.clear_audio()
	AudioManager.stop_background_track1()
	AudioManager.stop_background_track2()
	#AudioManager.play_background_track2(MusicResource.MusicType.BACKGROUND_AMBIENCE_LOOP)

func _on_play_again_pressed():
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS)
	get_tree().change_scene_to_file("res://UI/map_select.tscn")

func _on_main_menu_pressed():
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS)
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_button_mouse_entered() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_HOVER)
