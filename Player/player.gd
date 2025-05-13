extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hud: Control = $Camera2D/HUD

var SPEED: float = 400
var previous_velocity: Vector2

func _ready() -> void:
	animation_tree.active = true
	hud.position = get_viewport_rect().size * -1 / 2

func _process(delta: float) -> void:
	Global.player_position = global_position

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

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ghost"):
		Global.ghost_detected = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("Ghost"):
		Global.ghost_detected = false
