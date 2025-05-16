extends CharacterBody2D

enum GhostState {DETECTABLE, UNDETECTABLE}
enum GhostAction {DORMANT, MOVE, TELEPORT}

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var action_timer: Timer = $"Action Timer"

var rng: RandomNumberGenerator

var chasing: bool = false
var SPEED: float = 9750
var previous_velocity: Vector2
var dead: bool = false
var direction: Vector2
var player_detected: bool = false
var state_active: bool = false
var state_weights: PackedFloat32Array = PackedFloat32Array([20, 80])
var undetectable_action_weights: PackedFloat32Array = PackedFloat32Array([35, 25, 40])
var detectable_action_weights: PackedFloat32Array = PackedFloat32Array([26, 37, 37])

func _ready() -> void:
	Global.jikininki_node = self
	SignalBus.ghost_alerted.connect(_on_ghost_alerted)
	visible = false

func _process(_delta: float) -> void:
	Global.ghost_position = global_position
	
	if player_detected and chasing:
		SignalBus.hurt_player.emit()
	
	if not state_active and not chasing:
		_update_state()

func _physics_process(delta: float) -> void:
	
	var player_direction: Vector2 = Global.player_position - global_position
	
	if chasing:
		direction = (player_direction).normalized()
		SPEED = 20500
		collision_shape_2d.disabled = false
		visible = true
	
	if chasing and player_direction.length() < 20:
		velocity = Vector2.ZERO
	elif direction:
		velocity = direction * SPEED * delta
	else:
		velocity = Vector2.ZERO
	
	if player_direction.length() < 10 and velocity == Vector2.ZERO:
		global_position -= Vector2(player_direction.normalized())
	
	_update_animation()
	
	move_and_slide()

func _update_state() -> void:
	state_active = true
	rng = RandomNumberGenerator.new()
	var random_state_selection: int = rng.rand_weighted(state_weights)
	if random_state_selection == GhostState.DETECTABLE:
		Global.ghost_detectable = true
		collision_shape_2d.disabled = false
		#visible = true
		var random_action_selection: int = rng.rand_weighted(detectable_action_weights)
		if random_action_selection == GhostAction.DORMANT:
			# Do dormant things (no velocity, sounds?)
			await _run_action_timer(rng.randf_range(1, 10))
		elif random_action_selection == GhostAction.MOVE:
			# Do moving things (move to a random position?)
			_rand_move_to_position(rng.randf_range(9500, 15000))
			await _run_action_timer()
			direction = Vector2.ZERO
			await _run_action_timer(rng.randf_range(1, 5))
		elif random_action_selection == GhostAction.TELEPORT:
			# Do teleport things (change position to a spawn region)
			_rand_teleport_to_position()
			await _run_action_timer()
	elif random_state_selection == GhostState.UNDETECTABLE:
		Global.ghost_detectable = false
		collision_shape_2d.disabled = true
		#visible = false
		var random_action_selection: int = rng.rand_weighted(undetectable_action_weights)
		if random_action_selection == GhostAction.DORMANT:
			# Do dormant things (no velocity, sounds?)
			await _run_action_timer(rng.randf_range(5, 10))
		elif random_action_selection == GhostAction.MOVE:
			# Do moving things (move to a random position?)
			_rand_move_to_position(rng.randf_range(9500, 15000))
			await _run_action_timer()
			direction = Vector2.ZERO
			await _run_action_timer(rng.randf_range(1, 5))
		elif random_action_selection == GhostAction.TELEPORT:
			# Do teleport things (change position to a spawn region)
			_rand_teleport_to_position()
			await _run_action_timer()
	state_active = false

func _run_action_timer(wait_time: float = 5) -> void:
	action_timer.wait_time = wait_time
	action_timer.start()
	await action_timer.timeout

func _rand_move_to_position(speed: float = SPEED) -> void:
	var target_position: Vector2
	var world_boundary_region: SpawnerRect2D = Global.world_boundary_region
	var position_variation: Vector2 = Vector2(randf_range(0, world_boundary_region.rect_size.x), randf_range(0, world_boundary_region.rect_size.y))
	target_position = world_boundary_region.global_position + position_variation
	direction = (target_position - global_position).normalized()

func _rand_teleport_to_position() -> void:
	var target_position: Vector2
	var spawn_region = Global.spawn_regions.pick_random()
	var position_variation: Vector2 = Vector2(randf_range(-50, spawn_region.rect_size.x + 50), randf_range(-50, spawn_region.rect_size.y + 50))
	target_position = spawn_region.global_position + position_variation
	global_position = target_position

func _update_animation() -> void:
	if velocity != Vector2.ZERO:
		animation_tree.set("parameters/Run/blend_position", velocity)
		previous_velocity = velocity
	elif velocity == Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", previous_velocity)
	
	if velocity.x < 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = true

func _on_ghost_alerted() -> void:
	chasing = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		player_detected = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		player_detected = false
