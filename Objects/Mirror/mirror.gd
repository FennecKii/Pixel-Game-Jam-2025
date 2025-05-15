@tool
extends Node2D

enum MirrorDirection {FRONT, LEFT, RIGHT}

@export var mirror_type: MirrorDirection = MirrorDirection.FRONT

@onready var mirror_front: Sprite2D = $"Mirror Front"
@onready var mirror_side: Sprite2D = $"Mirror Side"
@onready var ui_animated_sprite: AnimatedSprite2D = $"Mirror UI/UI Animated Sprite"
@onready var detection_collision: CollisionShape2D = $"Player Detection/Detection"

func _ready() -> void:
	ui_animated_sprite.self_modulate = Color(1, 1, 1, 0)
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
		detection_collision.position = Vector2(0, 7.5)
	elif mirror_type == MirrorDirection.LEFT:
		mirror_side.flip_h = true
		mirror_front.visible = false
		mirror_side.visible = true
		detection_collision.position = Vector2(-8, 3)
	elif mirror_type == MirrorDirection.RIGHT:
		mirror_side.flip_h = false
		mirror_front.visible = false
		mirror_side.visible = true
		detection_collision.position = Vector2(8, 3)

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(ui_animated_sprite, "self_modulate", Color(1, 1, 1, 1), 0.5)

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(ui_animated_sprite, "self_modulate", Color(1, 1, 1, 0), 0.5)
