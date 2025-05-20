extends CharacterBody2D

enum GhostState {DETECTABLE, UNDETECTABLE}
enum GhostAction {DORMANT, MOVE, TELEPORT}

@export var ghost_type: int
@export var ghost_appearance: int

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var action_timer: Timer = $"Action Timer"
@onready var animated_sprite_2d: GhostAnimationComponent = $"Ghost Animated Sprite"
@onready var ghost_label: Label = $Name

var rng: RandomNumberGenerator

var animation_player: AnimationPlayer
var chasing: bool = false
var chase_sound_played: bool = false
var SPEED: float = 15000
var previous_velocity: Vector2
var dead: bool = false
var direction: Vector2
var player_detected: bool = false
var state_active: bool = false
var state_weights: PackedFloat32Array = PackedFloat32Array([60, 40])
var undetectable_action_weights: PackedFloat32Array = PackedFloat32Array([30, 20, 50])
var detectable_action_weights: PackedFloat32Array = PackedFloat32Array([38, 20, 42])
var footstep_audio_played: bool = false
var walk_audio_prob: float
var play_walk_audio: bool = false
var scream_audio_played: bool = false

func _ready() -> void:
	_set_ghost_type()
	Global.ghost_node = self
	SignalBus.ghost_alerted.connect(_on_ghost_alerted)
	animation_player = animated_sprite_2d.animation_player

func _process(_delta: float) -> void:
	Global.ghost_position = global_position
	
	if player_detected and chasing:
		if not scream_audio_played:
			AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.GHOST_SCREAM)
			scream_audio_played = true
		SignalBus.hurt_player.emit()
	
	if not state_active and not chasing:
		_update_state()

func _physics_process(delta: float) -> void:
	var player_direction: Vector2 = Global.player_position - global_position
	
	if chasing:
		if velocity:
			_update_footstep_audio(true)
		direction = (player_direction).normalized()
		SPEED = 50000
		Global.ghost_detectable = true
		collision_shape_2d.disabled = false
		visible = true
	
	if chasing and player_direction.length() < 20:
		velocity = Vector2.ZERO
	elif direction:
		if play_walk_audio:
			_update_footstep_audio()
		velocity = direction * SPEED * delta
	else:
		velocity = Vector2.ZERO
	
	if player_direction.length() < 10 and velocity == Vector2.ZERO:
		global_position -= Vector2(player_direction.normalized())
	
	_update_animation()
	
	move_and_slide()

func _update_footstep_audio(fast: bool = false) -> void:
	if not fast:
		if not footstep_audio_played:
			AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.GHOST_WALK_QUIET)
			footstep_audio_played = true
			await get_tree().create_timer(randf_range(0.5, 0.55)).timeout
			footstep_audio_played = false
	elif fast:
		if not footstep_audio_played:
			AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.GHOST_WALK)
			footstep_audio_played = true
			await get_tree().create_timer(randf_range(0.3, 0.35)).timeout
			footstep_audio_played = false

func _update_state() -> void:
	state_active = true
	rng = RandomNumberGenerator.new()
	var random_state_selection: int = rng.rand_weighted(state_weights)
	if random_state_selection == GhostState.DETECTABLE:
		if not Global.ghost_detectable:
			AudioManager.play_sfx_at_location(global_position, randi_range(SoundResource.SoundType.GHOST_DETECTABLE_1, SoundResource.SoundType.GHOST_DETECTABLE_2))
			Global.ghost_detectable = true
		collision_shape_2d.disabled = false
		var random_action_selection: int = rng.rand_weighted(detectable_action_weights)
		if random_action_selection == GhostAction.DORMANT:
			if randf_range(0, 1) <= 0.4:
				AudioManager.play_sfx_at_location(global_position, randi_range(SoundResource.SoundType.GHOST_BREATH_1, SoundResource.SoundType.GHOST_CRY_2))
			await _run_action_timer(rng.randf_range(3, 10))
		elif random_action_selection == GhostAction.MOVE:
			if randf_range(0, 1) <= 0.7:
				AudioManager.play_sfx_at_location(global_position, randi_range(SoundResource.SoundType.GHOST_WOOSH_1, SoundResource.SoundType.GHOST_WOOSH_2))
			walk_audio_prob = randf_range(0, 1)
			if walk_audio_prob <= 0.1:
				play_walk_audio = true
			_rand_move_to_position(rng.randf_range(5000, 10000))
			await _run_action_timer()
			direction = Vector2.ZERO
			play_walk_audio = false
			if randf_range(0, 1) <= 0.5:
				AudioManager.play_sfx_at_location(global_position, randi_range(SoundResource.SoundType.GHOST_WOOSH_1, SoundResource.SoundType.GHOST_WOOSH_2))
			await _run_action_timer(rng.randf_range(3, 7))
		elif random_action_selection == GhostAction.TELEPORT:
			AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.GHOST_TELEPORT_KNOCK)
			AudioManager.play_sfx_at_location(global_position, randi_range(SoundResource.SoundType.GHOST_LAUGH_1, SoundResource.SoundType.GHOST_LAUGH_2))
			_rand_teleport_to_position()
			await _run_action_timer(rng.randf_range(5, 8))
	elif random_state_selection == GhostState.UNDETECTABLE:
		if Global.ghost_detectable:
			Global.ghost_detectable = false
		collision_shape_2d.disabled = true
		var random_action_selection: int = rng.rand_weighted(undetectable_action_weights)
		if random_action_selection == GhostAction.DORMANT:
			if randf_range(0, 1) <= 0.4:
				AudioManager.play_sfx_at_location(global_position, randi_range(SoundResource.SoundType.GHOST_BREATH_1, SoundResource.SoundType.GHOST_CRY_2))
			await _run_action_timer(rng.randf_range(5, 10))
		elif random_action_selection == GhostAction.MOVE:
			if randf_range(0, 1) <= 0.7:
				AudioManager.play_sfx_at_location(global_position, randi_range(SoundResource.SoundType.GHOST_WOOSH_1, SoundResource.SoundType.GHOST_WOOSH_2))
			walk_audio_prob = randf_range(0, 1)
			if walk_audio_prob <= 0.1:
				play_walk_audio = true
			_rand_move_to_position(rng.randf_range(5000, 10000))
			await _run_action_timer()
			direction = Vector2.ZERO
			play_walk_audio = false
			if randf_range(0, 1) <= 0.5:
				AudioManager.play_sfx_at_location(global_position, randi_range(SoundResource.SoundType.GHOST_WOOSH_1, SoundResource.SoundType.GHOST_WOOSH_2))
			await _run_action_timer(rng.randf_range(1, 5))
		elif random_action_selection == GhostAction.TELEPORT:
			AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.GHOST_TELEPORT_KNOCK)
			AudioManager.play_sfx_at_location(global_position, randi_range(SoundResource.SoundType.GHOST_LAUGH_1, SoundResource.SoundType.GHOST_LAUGH_2))
			_rand_teleport_to_position()
			await _run_action_timer(rng.randf_range(1, 5))
	state_active = false

func _run_action_timer(wait_time: float = 5) -> void:
	action_timer.wait_time = wait_time
	action_timer.start()
	await action_timer.timeout

func _rand_move_to_position(speed: float = SPEED) -> void:
	var target_position: Vector2
	var world_boundary_region: SpawnerRect2D = Global.world_boundaries.pick_random()
	var position_variation: Vector2 = Vector2(randf_range(0, world_boundary_region.rect_size.x), randf_range(0, world_boundary_region.rect_size.y))
	target_position = world_boundary_region.global_position + position_variation
	direction = (target_position - global_position).normalized()
	SPEED = speed

func _rand_teleport_to_position() -> void:
	var target_position: Vector2
	var spawn_region = Global.spawn_regions.pick_random()
	var position_variation: Vector2 = Vector2(randf_range(0, spawn_region.rect_size.x), randf_range(0, spawn_region.rect_size.y))
	target_position = spawn_region.global_position + position_variation
	global_position = target_position

func _update_animation() -> void:
	if velocity != Vector2.ZERO:
		if ghost_appearance == Global.GhostAppearance.DEFAULT:
			animation_player.active = true
			animation_player.play("run")
		elif ghost_appearance == Global.GhostAppearance.BLUE:
			animation_player.active = false
			animated_sprite_2d.play("blue walk")
		elif ghost_appearance == Global.GhostAppearance.UNDEAD:
			animation_player.active = false
			var direction_enum: int = _determine_direction(velocity)
			if direction_enum == Global.SpriteDirection.DOWN:
				animated_sprite_2d.play("undead walk down")
			elif direction_enum == Global.SpriteDirection.UP:
				animated_sprite_2d.play("undead walk up")
			elif direction_enum == Global.SpriteDirection.SIDE:
				animated_sprite_2d.play("undead walk side")
		previous_velocity = velocity
	elif velocity == Vector2.ZERO:
		if ghost_appearance == Global.GhostAppearance.DEFAULT:
			animation_player.active = true
			animation_player.play("idle")
		elif ghost_appearance == Global.GhostAppearance.BLUE:
			animation_player.active = false
			animated_sprite_2d.play("blue idle")
		elif ghost_appearance == Global.GhostAppearance.UNDEAD:
			animation_player.active = false
			var direction_enum: int = _determine_direction(previous_velocity)
			if direction_enum == Global.SpriteDirection.DOWN:
				animated_sprite_2d.play("undead idle down")
			elif direction_enum == Global.SpriteDirection.UP:
				animated_sprite_2d.play("undead idle up")
			elif direction_enum == Global.SpriteDirection.SIDE:
				animated_sprite_2d.play("undead idle side")
	
	if velocity.x < 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = true

func _determine_direction(velocity_vec: Vector2) -> int:
	if abs(velocity_vec.x) >= abs(velocity_vec.y):
		return Global.SpriteDirection.SIDE
	elif velocity_vec.y > 0 and velocity_vec.y > abs(velocity_vec.x):
		return Global.SpriteDirection.DOWN
	elif velocity_vec.y < 0 and abs(velocity_vec.y) > abs(velocity_vec.x):
		return Global.SpriteDirection.UP
	else:
		return Global.SpriteDirection.UNKNOWN

func _on_ghost_alerted() -> void:
	if not chase_sound_played:
		AudioManager.play_sfx_global(SoundResource.SoundType.GAME_ENEMY_REVEAL)
		chase_sound_played = true
		await get_tree().create_timer(3.75).timeout
		var rand_angle: float = randf_range(0, 2*PI)
		global_position = Global.player_position + Vector2(cos(rand_angle), sin(rand_angle)) * 1000
		chasing = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		player_detected = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body == Global.player_node:	
		player_detected = false

func _set_ghost_type():
	if ghost_type == Global.GhostNames.YUKIONNA:
		ghost_label.text = "Yuki Onna"
	elif ghost_type == Global.GhostNames.ONRYO:
		ghost_label.text = "Onryo"
	elif ghost_type == Global.GhostNames.JIKININKI:
		ghost_label.text = "Jikininki"
