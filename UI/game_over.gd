extends Node2D

var ambient_audio_played: bool = false
var scene_iniatlized: bool = false

func _ready() -> void:
	AudioManager.play_background_track2(MusicResource.MusicType.BACKGROUND_AMBIENCE_LOOP)
	await get_tree().create_timer(1).timeout
	AudioManager.play_sfx_global(randi_range(SoundResource.SoundType.AMBIENT_KNOCK_1, SoundResource.SoundType.AMBIENT_KNOCK_2))

func _process(_delta: float) -> void:
	if not scene_iniatlized:
		await get_tree().create_timer(10).timeout
		scene_iniatlized = true
	elif not ambient_audio_played:
		if randf_range(0, 1) <= 0.025:
			ambient_audio_played = true
			AudioManager.play_sfx_global(randi_range(SoundResource.SoundType.AMBIENT_KNOCK_1, SoundResource.SoundType.AMBIENT_WHISPER))
			await get_tree().create_timer(10).timeout
			ambient_audio_played = false

func _on_pressed_play_again() -> void:
	get_tree().change_scene_to_file("res://UI/map_select.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
