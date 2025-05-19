extends Node2D

@onready var tutorial_btn = $Map/Tutorial
@onready var little_village_btn = $Map/LittleVillage
@onready var big_village_btn = $Map/BigVillage

func _ready():
	update_button_states()

func update_button_states():
	tutorial_btn.disabled = false

	little_village_btn.disabled = Global.wincount < 1
	big_village_btn.disabled = Global.wincount < 2

func _on_map1_pressed():
	await _play_button_audio()
	get_tree().change_scene_to_file("res://Maps/Map 1/map_1.tscn")

func _on_map_2_pressed() -> void:
	await _play_button_audio()
	get_tree().change_scene_to_file("res://Maps/Map2/map2.tscn")

func _on_map_3_pressed() -> void:
	await _play_button_audio()
	get_tree().change_scene_to_file("res://Maps/Tutorial/tutorial_map.tscn")

func _play_button_audio() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS)
	await get_tree().create_timer(0.05).timeout
	AudioManager.play_sfx_global(randi_range(SoundResource.SoundType.BUTTON_HAUNT_1, SoundResource.SoundType.BUTTON_HAUNT_2))

func _on_button_mouse_entered() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_HOVER)
