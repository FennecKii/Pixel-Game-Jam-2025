extends Node2D

var sound_effect_dict: Dictionary = {}

@export var sound_effects: Array[SoundEffect]

func _ready() -> void:
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect

func play_sfx_at_location(location: Vector2, type: SoundEffect.SoundEffectType) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		var new_2D_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		new_2D_audio.position = location
		new_2D_audio.bus = sound_effect.bus
		new_2D_audio.stream = sound_effect.sound
		new_2D_audio.volume_db = sound_effect.volume
		new_2D_audio.pitch_scale = sound_effect.pitch_scale
		new_2D_audio.pitch_scale += Global.rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
		new_2D_audio.finished.connect(new_2D_audio.queue_free)
		add_child(new_2D_audio)
		new_2D_audio.play()
	else:
		push_error("Audio Manager failed to find type ", type)

func play_sfx_global(type: SoundEffect.SoundEffectType) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		new_audio.bus = sound_effect.bus
		new_audio.stream = sound_effect.sound
		new_audio.volume_db = sound_effect.volume
		new_audio.pitch_scale = sound_effect.pitch_scale
		new_audio.pitch_scale += Global.rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
		new_audio.finished.connect(new_audio.queue_free)
		add_child(new_audio)
		new_audio.play()
	else:
		push_error("Audio Manager failed to find type ", type)
