extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

var SPEED: float = 100
var previous_velocity: Vector2
var dead: bool = false
var chasing: bool = true
var direction: Vector2

func _process(delta: float) -> void:
	Global.ghost_position = global_position

func _physics_process(delta: float) -> void:
	
	var player_direction: Vector2 = Global.player_position - global_position
	
	if chasing:
		Global.ghost_detected = true
		direction = (player_direction).normalized()
	
	if direction and vec_len(player_direction) > 50:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	update_animation()
	
	move_and_slide()

func update_animation() -> void:
	if velocity != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", velocity)
		previous_velocity = velocity
	elif velocity == Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", previous_velocity)
	
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false

func vec_len(vector: Vector2) -> float:
	return sqrt((vector.x ** 2) + (vector.y ** 2))
