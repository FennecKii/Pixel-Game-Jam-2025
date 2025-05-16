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
var current_state: GhostState = GhostState.DETECTABLE
var state_active: bool = false
var state_weights: PackedFloat32Array = PackedFloat32Array([25, 75])
var action_weights: PackedFloat32Array = PackedFloat32Array([25, 25, 50])

func _ready() -> void:
	Global.yuki_onna_node = self
	SignalBus.ghost_alerted.connect(_on_ghost_alerted)

func _process(_delta: float) -> void:
	Global.ghost_position = global_position
	
	if player_detected and chasing:
		SignalBus.hurt_player.emit()
	
	if not state_active:
		_update_ai()

func _physics_process(delta: float) -> void:
	var player_direction: Vector2 = Global.player_position - global_position
	
	if chasing:
		direction = (player_direction).normalized()
	
	if direction and player_direction.length() > 20:
		velocity = direction * SPEED * delta
	else:
		velocity = Vector2.ZERO
	
	if player_direction.length() < 2 and velocity == Vector2.ZERO:
		global_position -= Vector2(player_direction.normalized())
	
	_update_animation()
	
	move_and_slide()

func _update_ai() -> void:
	state_active = true
	rng = RandomNumberGenerator.new()
	var random_state_selection: int = rng.rand_weighted(state_weights)
	if random_state_selection == GhostState.DETECTABLE:
		current_state = GhostState.DETECTABLE
		collision_shape_2d.disabled = false
		visible = true
		print("Detectable")
		var random_action_selection: int = rng.rand_weighted(action_weights)
		if random_action_selection == GhostAction.DORMANT:
			# Do dormant things (no velocity, sounds?)
			print("Dormant")
			await _run_action_timer()
			print("Action timer finished")
		elif random_action_selection == GhostAction.MOVE:
			# Do moving things (move to a random position?)
			print("Moving")
			await _run_action_timer()
			print("Action timer finished")
		elif random_action_selection == GhostAction.TELEPORT:
			# Do teleport things (change position to a spawn region)
			print("Teleporting")
			await _run_action_timer()
			print("Action timer finished")
	elif random_state_selection == GhostState.UNDETECTABLE:
		current_state == GhostState.UNDETECTABLE
		collision_shape_2d.disabled = true
		visible = false
		print("Undetectable")
		var random_action_selection: int = rng.rand_weighted(action_weights)
		if random_action_selection == GhostAction.DORMANT:
			# Do dormant things (no velocity, sounds?)
			print("Dormant")
			await _run_action_timer()
			print("Action timer finished")
		elif random_action_selection == GhostAction.MOVE:
			# Do moving things (move to a random position?)
			print("Moving")
			await _run_action_timer()
			print("Action timer finished")
		elif random_action_selection == GhostAction.TELEPORT:
			# Do teleport things (change position to a spawn region)
			print("Teleporting")
			await _run_action_timer()
			print("Action timer finished")
	state_active = false

func _run_action_timer(wait_time: float = 5) -> void:
	action_timer.wait_time = wait_time
	action_timer.start()
	await action_timer.timeout

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
