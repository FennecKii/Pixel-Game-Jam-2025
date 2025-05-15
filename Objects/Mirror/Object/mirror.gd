@tool
extends Node2D

enum MirrorDirection {FRONT, LEFT, RIGHT}

@export var mirror_type: MirrorDirection = MirrorDirection.FRONT

@onready var mirror_front: Sprite2D = $"Mirror Front"
@onready var mirror_side: Sprite2D = $"Mirror Side"

func _ready() -> void:
	_update_mirror_sprite()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		pass
	else:
		_update_mirror_sprite()

func _update_mirror_sprite() -> void:
	if mirror_type == MirrorDirection.FRONT:
		mirror_front.visible = true
		mirror_side.visible = false
	elif mirror_type == MirrorDirection.LEFT:
		mirror_side.flip_h = true
		mirror_front.visible = false
		mirror_side.visible = true
	elif mirror_type == MirrorDirection.RIGHT:
		mirror_side.flip_h = false
		mirror_front.visible = false
		mirror_side.visible = true
