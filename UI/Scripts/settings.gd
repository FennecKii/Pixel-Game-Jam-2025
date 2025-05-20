extends Control

@onready var master_volume: HSlider = %MasterVolume
@onready var music_volume: HSlider = %MusicVolume
@onready var sfx_volume: HSlider = %SFXVolume

func _ready() -> void:
	AudioServer.set_bus_volume_db(0, Global.master_volume)
	AudioServer.set_bus_volume_db(1, Global.music_volume)
	AudioServer.set_bus_volume_db(2, Global.sfx_volume)
	master_volume.value = Global.master_volume
	music_volume.value = Global.music_volume
	sfx_volume.value = Global.sfx_volume
	SignalBus.settings_entered.connect(_on_settings_entered)

func _on_master_volume_changed(value) -> void:
	if value == -20.0:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
	AudioServer.set_bus_volume_db(0, value)
	Global.master_volume = value

func _on_music_volume_changed(value) -> void:
	if value == -20.0:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
	AudioServer.set_bus_volume_db(1, value)
	Global.music_volume = value

func _on_sfx_volume_changed(value) -> void:
	if value == -20.0:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
	AudioServer.set_bus_volume_db(2, value)
	Global.sfx_volume = value

func _on_close_pressed() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS_NOTEBOOK)
	self.visible = false

func _on_button_entered() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_HOVER)

func _on_drag_started() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS_NOTEBOOK)

func _on_settings_entered() -> void:
	AudioServer.set_bus_volume_db(0, Global.master_volume)
	AudioServer.set_bus_volume_db(1, Global.music_volume)
	AudioServer.set_bus_volume_db(2, Global.sfx_volume)
	master_volume.value = Global.master_volume
	music_volume.value = Global.music_volume
	sfx_volume.value = Global.sfx_volume
	
