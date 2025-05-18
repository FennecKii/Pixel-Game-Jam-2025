extends Node2D

@export var music_tracks: Array[MusicResource]
@export var sound_effects: Array[SoundResource]

@onready var main_background_music: AudioStreamPlayer = $"Main Background Music"

var music_track_dict: Dictionary = {}
var sound_effect_dict: Dictionary = {}

func _ready() -> void:
	for sound_effect: SoundResource in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect
	for music_track: MusicResource in music_tracks:
		music_track_dict[music_track.type] = music_track

func play_music_background(type: MusicResource.MusicType) -> void:
	if main_background_music.stream == music_track_dict[type].sound:
		return
	else:
		var music_track: MusicResource = music_track_dict[type]
		main_background_music.bus = "Music"
		main_background_music.stream = music_track.sound
		main_background_music.stream.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD
		main_background_music.stream.loop_begin = 0
		main_background_music.stream.loop_end = int(10*float(music_track.sound.mix_rate))
		main_background_music.volume_db = music_track.volume
		main_background_music.pitch_scale = music_track.pitch_scale
		main_background_music.pitch_scale += Global.rng.randf_range(-music_track.pitch_randomness, music_track.pitch_randomness )
		main_background_music.play()

func play_music(type: MusicResource.MusicType) -> void:
	if music_track_dict.has(type):
		var music_track: MusicResource = music_track_dict[type]
		var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		new_audio.bus = "Music"
		new_audio.stream = music_track.sound
		new_audio.stream.set_loop_mode(AudioStreamWAV.LoopMode.LOOP_FORWARD)
		new_audio.volume_db = music_track.volume
		new_audio.pitch_scale = music_track.pitch_scale
		new_audio.pitch_scale += Global.rng.randf_range(-music_track.pitch_randomness, music_track.pitch_randomness )
		add_child(new_audio)
		new_audio.play()
	else:
		push_error("Audio Manager failed to find type ", type)

#TODO
func music_loop():
	pass

func music_fade():
	pass

func sfx_loop():
	pass

func sfx_repeat():
	pass

func play_sfx_at_location(location: Vector2, type: SoundResource.SoundType) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundResource = sound_effect_dict[type]
		var new_2D_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		new_2D_audio.position = location
		new_2D_audio.bus = "SFX"
		new_2D_audio.stream = sound_effect.sound
		new_2D_audio.volume_db = sound_effect.volume
		new_2D_audio.pitch_scale = sound_effect.pitch_scale
		new_2D_audio.pitch_scale += Global.rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
		new_2D_audio.finished.connect(new_2D_audio.queue_free)
		add_child(new_2D_audio)
		new_2D_audio.play()
	else:
		push_error("Audio Manager failed to find type ", type)

func play_sfx_global(type: SoundResource.SoundType) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundResource = sound_effect_dict[type]
		var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		new_audio.bus = "SFX"
		new_audio.stream = sound_effect.sound
		new_audio.volume_db = sound_effect.volume
		new_audio.pitch_scale = sound_effect.pitch_scale
		new_audio.pitch_scale += Global.rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
		new_audio.finished.connect(new_audio.queue_free)
		add_child(new_audio)
		new_audio.play()
	else:
		push_error("Audio Manager failed to find type ", type)
