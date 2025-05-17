@tool
extends Node2D

enum MirrorDirection {FRONT, LEFT, RIGHT}

@export var mirror_type: MirrorDirection = MirrorDirection.FRONT

@onready var mirror_front: Sprite2D = $"Mirror Front"
@onready var mirror_side: Sprite2D = $"Mirror Side"
@onready var ui_animated_sprite: AnimatedSprite2D = $"Mirror UI/UI Animated Sprite"
@onready var player_detection_collision: CollisionShape2D = $"Player Detection/Detection"
@onready var ghost_silhouette_sprite: Sprite2D = $"Mirror UI/Mirror Ghost Silhouette"
@onready var ghost_detection_component: GhostDetectionComponent = $"Ghost Detection Component"
@onready var ui_animation_player: AnimationPlayer = $"Mirror UI/UI Animated Sprite/AnimationPlayer"

var silhouette_rgb_value: float = 48/255.0
var mirror_showing: bool = false

func _ready() -> void:
	ui_animated_sprite.self_modulate = Color(1, 1, 1, 0)
	ghost_silhouette_sprite.self_modulate = Color(silhouette_rgb_value, silhouette_rgb_value, silhouette_rgb_value, 0) 
	_update_mirror_sprite()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if mirror_showing:
			await _update_mirror_response()
		elif not mirror_showing:
			ui_animation_player.stop()
	else:
		_update_mirror_sprite()
		ui_animated_sprite.self_modulate = Color(1, 1, 1, 1)


func _update_mirror_sprite() -> void:
	if mirror_type == MirrorDirection.FRONT:
		mirror_front.visible = true
		mirror_side.visible = false
		player_detection_collision.position = Vector2(0, 7.5)
		ghost_detection_component.position = Vector2(0, 36)
	elif mirror_type == MirrorDirection.LEFT:
		mirror_side.flip_h = true
		mirror_front.visible = false
		mirror_side.visible = true
		player_detection_collision.position = Vector2(-8, 3)
		ghost_detection_component.position = Vector2(-56, 3)
	elif mirror_type == MirrorDirection.RIGHT:
		mirror_side.flip_h = false
		mirror_front.visible = false
		mirror_side.visible = true
		player_detection_collision.position = Vector2(8, 3)
		ghost_detection_component.position = Vector2(56, 3)

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(ui_animated_sprite, "self_modulate", Color(1, 1, 1, 1), 0.5)
		mirror_showing = true

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(ui_animated_sprite, "self_modulate", Color(1, 1, 1, 0), 0.5)
		mirror_showing = false

func _update_mirror_response() -> void:
	if not ghost_detection_component.ghost_detected:
		return
	elif ghost_detection_component.ghost_detected and ghost_detection_component.ghost_type == Global.yuki_onna_node:
		ui_animation_player.play("ghost_appear")
		await ui_animation_player.animation_finished
	elif ghost_detection_component.ghost_detected and ghost_detection_component.ghost_type == Global.onryo_node:
		ui_animation_player.play("ghost_appear")
		await ui_animation_player.animation_finished
	elif ghost_detection_component.ghost_detected and ghost_detection_component.ghost_type == Global.jikininki_node:
		ui_animation_player.play("crack")
		await ui_animation_player.animation_finished
