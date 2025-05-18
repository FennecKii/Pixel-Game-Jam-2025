class_name SoundEffect
extends Resource

enum SoundEffectType {
	
}

@export var type: SoundEffectType
@export_enum("Master", "SFX", "Music") var audio_bus: String
@export var sound: AudioStreamMP3
@export_range(-40, 20, 1) var volume: float = 0
@export_range(0.0, 4.0, 0.01) var pitch_scale: float = 1.0
@export_range(0.0, 4.0, 0.01) var pitch_randomness: float = 0
