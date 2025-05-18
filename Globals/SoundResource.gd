class_name SoundResource
extends Resource

enum SoundType {
	
}

@export var type: SoundType
@export var sound: AudioStreamMP3
@export_range(-40, 20, 1) var volume: float = 0
@export_range(0.0, 4.0, 0.01) var pitch_scale: float = 1.0
@export_range(0.0, 4.0, 0.01) var pitch_randomness: float = 0
