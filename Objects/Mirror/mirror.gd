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
var mirror_audio_played: bool = false
var mirror_cracked: bool = false
var mirror_reacting: bool = false

func _ready() -> void:
	ui_animated_sprite.self_modulate = Color(1, 1, 1, 0)
	ghost_silhouette_sprite.self_modulate = Color(silhouette_rgb_value, silhouette_rgb_value, silhouette_rgb_value, 0) 
	_update_mirror_sprite()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if not mirror_reacting and mirror_showing and not mirror_cracked:
			await _update_mirror_response()
			await get_tree().create_timer(randf_range(3, 5)).timeout
			mirror_reacting = false
		elif not mirror_showing:
			ui_animation_player.stop()
	else:
		_update_mirror_sprite()
		ui_animated_sprite.self_modulate = Color(1, 1, 1, 1)
	
	if mirror_cracked and mirror_showing:
		ui_animated_sprite.play("cracked")
		ui_animation_player.play("cracked")


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
	mirror_reacting = true
	if not ghost_detection_component.ghost_detected:
		return
	elif ghost_detection_component.ghost_detected and ghost_detection_component.ghost_type == Global.GhostNames.YUKIONNA:
		if randf_range(0, 1) <= 0.6:
			ui_animation_player.play("ghost_appear")
			if not mirror_audio_played:
				AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.OBJECT_MIRROR_APPEAR)
				mirror_audio_played = true
			await ui_animation_player.animation_finished
	elif ghost_detection_component.ghost_detected and ghost_detection_component.ghost_type == Global.GhostNames.ONRYO:
		if not mirror_audio_played and randf_range(0, 1) <= 0.4:
			var rand_anim: String = ["ghost_appear", "crack"].pick_random()
			mirror_audio_played = true
			print(rand_anim)
			if rand_anim == "ghost_appear":
				ui_animation_player.play(rand_anim)
				AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.OBJECT_MIRROR_APPEAR)
			elif rand_anim == "crack":
				mirror_cracked = true
				ui_animation_player.play(rand_anim)
				AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.OBJECT_MIRROR_BREAK)
			await ui_animation_player.animation_finished
			if rand_anim == "mirror crack":
				ui_animation_player.play("cracked")
	elif ghost_detection_component.ghost_detected and ghost_detection_component.ghost_type == Global.GhostNames.JIKININKI:
		if not mirror_cracked and randf_range(0, 1) <= 0.4:
			ui_animation_player.play("crack")
			if not mirror_audio_played:
				mirror_cracked = true
				AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.OBJECT_MIRROR_BREAK)
				mirror_audio_played = true
			await ui_animation_player.animation_finished
