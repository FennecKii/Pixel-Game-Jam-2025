extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

var SPEED: float = 350
var previous_velocity: Vector2
var dead: bool = false
var chasing: bool = true
var direction: Vector2

func _process(delta: float) -> void:
	Global.ghost_position = global_position

func _physics_process(delta: float) -> void:
	
	var player_direction: Vector2 = Global.player_position - global_position
	
	if chasing:
		direction = (player_direction).normalized()
	
	if direction and Global.vec_len(player_direction) > 70:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	if Global.vec_len(player_direction) < 60 and velocity == Vector2.ZERO:
		global_position -= Vector2(player_direction.normalized())
	
	_update_animation()
	
	move_and_slide()

func _update_animation() -> void:
	if velocity != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", velocity)
		previous_velocity = velocity
	elif velocity == Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", previous_velocity)
	
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
