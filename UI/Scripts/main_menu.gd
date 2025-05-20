extends Node2D

@onready var settings: Control = %Settings

var ambient_audio_played: bool = false

func _ready() -> void:
	AudioManager.play_background_track2(MusicResource.MusicType.BACKGROUND_AMBIENCE_LOOP)

func _process(_delta: float) -> void:
	if not ambient_audio_played:
		if randf_range(0, 1) <= 0.025:
			ambient_audio_played = true
			AudioManager.play_sfx_global(randi_range(SoundResource.SoundType.AMBIENT_KNOCK_1, SoundResource.SoundType.AMBIENT_KNOCK_2))
			await get_tree().create_timer(randf_range(10, 20)).timeout
			ambient_audio_played = false

func _on_pressed_play():
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS)
	get_tree().change_scene_to_file("res://UI/Scenes/map_select.tscn")

func _on_pressed_quit():
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS)
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()

func _on_settings_pressed() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS)
	settings.visible = true
	SignalBus.settings_entered.emit()

func _on_button_mouse_entered() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_HOVER)
