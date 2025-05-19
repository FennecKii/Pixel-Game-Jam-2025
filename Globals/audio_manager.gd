extends Node2D

@export var music_tracks: Array[MusicResource]
@export var sound_effects: Array[SoundResource]

@onready var main_background_music: AudioStreamPlayer = $"Main Background Music"
@onready var background_track_1: AudioStreamPlayer = $"Background Track 1"
@onready var background_track_2: AudioStreamPlayer = $"Background Track 2"
@onready var audio_players: Node2D = $"Audio Players"

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
	elif music_track_dict.has(type):
		var music_track: MusicResource = music_track_dict[type]
		main_background_music.bus = "Music"
		main_background_music.stream = music_track.sound
		main_background_music.volume_db = music_track.volume
		main_background_music.pitch_scale = music_track.pitch_scale
		main_background_music.pitch_scale += Global.rng.randf_range(-music_track.pitch_randomness, music_track.pitch_randomness )
		main_background_music.play()
	else:
		push_error("Audio Manager failed to find type ", type)

func play_background_track1(type: MusicResource.MusicType, loop_begin: float = 0, loop_end: float = -1) -> void:
	if background_track_1.stream == music_track_dict[type].sound:
		return
	elif music_track_dict.has(type):
		var music_track: MusicResource = music_track_dict[type]
		background_track_1.bus = "Music"
		background_track_1.stream = music_track.sound
		background_track_1.stream.loop_begin = loop_begin * music_track.sound.mix_rate
		if loop_end == -1:
			background_track_1.stream.loop_end = music_track.sound.get_length() * music_track.sound.mix_rate
		else:
			background_track_1.stream.loop_end = loop_end * music_track.sound.mix_rate
		background_track_1.volume_db = music_track.volume
		background_track_1.pitch_scale = music_track.pitch_scale
		background_track_1.pitch_scale += Global.rng.randf_range(-music_track.pitch_randomness, music_track.pitch_randomness )
		background_track_1.play()
	else:
		push_error("Audio Manager failed to find type ", type)

func stop_background_track1():
	background_track_1.stop()

func play_background_track2(type: MusicResource.MusicType, loop_begin: float = 0, loop_end: float = -1) -> void:
	if background_track_2.stream == music_track_dict[type].sound:
		return
	elif music_track_dict.has(type):
		var music_track: MusicResource = music_track_dict[type]
		background_track_2.bus = "Music"
		background_track_2.stream = music_track.sound
		background_track_2.stream.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD
		background_track_2.stream.loop_begin = loop_begin * music_track.sound.mix_rate
		if loop_end == -1:
			background_track_2.stream.loop_end = music_track.sound.get_length() * music_track.sound.mix_rate
		else:
			background_track_2.stream.loop_end = loop_end * music_track.sound.mix_rate
		background_track_2.volume_db = music_track.volume
		background_track_2.pitch_scale = music_track.pitch_scale
		background_track_2.pitch_scale += Global.rng.randf_range(-music_track.pitch_randomness, music_track.pitch_randomness )
		background_track_2.play()
	else:
		push_error("Audio Manager failed to find type ", type)

func stop_background_track2():
	background_track_2.stop()

func play_music(type: MusicResource.MusicType) -> void:
	if music_track_dict.has(type):
		var music_track: MusicResource = music_track_dict[type]
		var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		new_audio.bus = "Music"
		new_audio.stream = music_track.sound
		new_audio.volume_db = music_track.volume
		new_audio.pitch_scale = music_track.pitch_scale
		new_audio.pitch_scale += Global.rng.randf_range(-music_track.pitch_randomness, music_track.pitch_randomness )
		audio_players.add_child(new_audio)
		new_audio.play()
	else:
		push_error("Audio Manager failed to find type ", type)

func play_music_loop(type: MusicResource.MusicType, loop_begin: float = 0, loop_end: float = -1) -> void:
	if music_track_dict.has(type):
		var music_track: MusicResource = music_track_dict[type]
		var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		new_audio.bus = "Music"
		new_audio.stream = music_track.sound
		new_audio.stream.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD
		new_audio.stream.loop_begin = loop_begin * music_track.sound.mix_rate
		if loop_end == -1:
			new_audio.stream.loop_end = music_track.sound.get_length() * music_track.sound.mix_rate
		else:
			new_audio.stream.loop_end = loop_end * music_track.sound.mix_rate
		new_audio.volume_db = music_track.volume
		new_audio.pitch_scale = music_track.pitch_scale
		new_audio.pitch_scale += Global.rng.randf_range(-music_track.pitch_randomness, music_track.pitch_randomness )
		audio_players.add_child(new_audio)
		new_audio.play()
	else:
		push_error("Audio Manager failed to find type ", type)

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
		audio_players.add_child(new_2D_audio)
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
		audio_players.add_child(new_audio)
		new_audio.play()
	else:
		push_error("Audio Manager failed to find type ", type)

func clear_audio() -> void:
	var audio_players_children: Array[Node] = audio_players.get_children()
	
	for audio in audio_players_children:
		audio.queue_free()

func lower_audio() -> void:
	var audio_players_children: Array[Node] = audio_players.get_children()
	
	for audio in audio_players_children:
		audio.volume_db = audio.volume_db/2.5
