extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

var SPEED: float = 250
var previous_velocity: Vector2

func _ready() -> void:
	animation_tree.active = true
	update_animation()

func _physics_process(_delta: float) -> void:
	
	var direction: Vector2 = Input.get_vector("Left", "Right", "Up", "Down").normalized()
	
	if direction:
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
