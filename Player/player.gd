extends CharacterBody2D

@export var ghost_detection_component: GhostDetectionComponent

@onready var animated_sprite_2d:  AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var bell: Node2D = %Bell
@onready var ofuda: Node2D = %Ofuda
@onready var ofuda_outline: Sprite2D = %"Ofuda Outline"
@onready var ofuda_radius: Area2D = $"Ofuda Radius"
@onready var error_message: Label = %"Error Message"
@onready var player_health: int = Global.player_max_health

var SPEED: float = 40000
var previous_velocity: Vector2
var can_place: bool = false
var bell_volume: float
var ofuda_count: int = 0
var is_dead: bool = false

func _ready() -> void:
	Global.player_node = self
	Global.player_ghost_detected = ghost_detection_component.ghost_detected
	SignalBus.ofuda_pickedup.connect(_on_ofuda_pickedup)
	SignalBus.hurt_player.connect(_on_player_hurt)
	animation_tree.active = true

func _process(_delta: float) -> void:
	Global.player_position = global_position
	Global.player_ghost_detected = ghost_detection_component.ghost_detected
	
	_update_item_states()
	
	_handle_item_input()
	
	_check_player_health()

func _physics_process(delta: float) -> void:
	
	var direction: Vector2 = Input.get_vector("Left", "Right", "Up", "Down").normalized()
	
	if direction:
		velocity = direction * SPEED * delta
	else:
		velocity = Vector2.ZERO
	
	_update_animation()
	
	move_and_slide()

func _check_player_health() -> void:
	if player_health <= 0:
		is_dead = true
		velocity = Vector2.ZERO
		_handle_death()
	elif player_health > 0:
		is_dead = false

func _handle_death() -> void:
	await animation_tree.animation_finished
	SignalBus.player_dead.emit()

func _update_animation() -> void:
	if velocity != Vector2.ZERO:
		animation_tree.set("parameters/Run/blend_position", velocity)
		previous_velocity = velocity
	elif velocity == Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", previous_velocity)
	
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false

func _update_item_states() -> void:
	if ofuda_count == 2 or not can_place:
		ofuda_outline.self_modulate.r = 0.75
		ofuda_outline.self_modulate.b = 0
		ofuda_outline.self_modulate.g = 0
		ofuda_outline.self_modulate.a = 0.75
	
	if ofuda_count < 2 and can_place:
		ofuda_outline.self_modulate.b = 0
		ofuda_outline.self_modulate.r = 0
		ofuda_outline.self_modulate.g = 0.75
		ofuda_outline.self_modulate.a = 0.75
	
	Global.bell_equipped = bell.visible
	Global.ofuda_equipped = ofuda.visible
	ofuda_outline.global_position = get_global_mouse_position()

func _handle_item_input() -> void:
	# Equip or Switch Items
	if Input.is_action_just_pressed("Equip Bell") and not Global.bell_equipped:
		bell.visible = true
		ofuda.visible = false
		ofuda_outline.visible = false
	elif Input.is_action_just_pressed("Equip Ofuda") and not Global.ofuda_equipped:
		ofuda.visible = true
		bell.visible = false
		ofuda_outline.visible = true
	
	# Unequip Items
	if Input.is_action_just_pressed("Equip Bell") and Global.bell_equipped:
		bell.visible = false
	elif Input.is_action_just_pressed("Equip Ofuda") and Global.ofuda_equipped:
		ofuda.visible = false
		ofuda_outline.visible = false
	
	# Use Items
	if Input.is_action_just_pressed("Use Item") and Global.bell_equipped:
		SignalBus.bell_rang.emit(bell_volume)
	elif Input.is_action_just_pressed("Use Item") and Global.ofuda_equipped:
		if ofuda_count < 2 and can_place:
			ofuda_count += 1
			SignalBus.ofuda_placed.emit()
			SignalBus.ofuda_count_changed.emit(ofuda_count)
			_place_ofuda(get_global_mouse_position())
		elif ofuda_count == 2 and not error_message.visible:
			error_message.visible = true
			error_message.text = "No more Ofuda left!"
			await get_tree().create_timer(2).timeout
			error_message.visible = false
		elif not can_place and not error_message.visible:
			error_message.visible = true
			error_message.text = "Too far!"
			await get_tree().create_timer(1).timeout
			error_message.visible = false

func _place_ofuda(map_position: Vector2) -> void:
	var ofuda_instance := Global.ofuda_scene.instantiate()
	ofuda_instance.global_position = map_position
	ofuda_instance.ofuda_placed = true
	ofuda_instance.scale = Vector2(3, 3)
	if Global.world_objects_node:
		Global.world_objects_node.add_child(ofuda_instance)
	elif Global.world_node:
		Global.world_node.add_child(ofuda_instance)

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ghost"):
		Global.player_ghost_detected = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("Ghost"):
		Global.player_ghost_detected = false

func _on_ofuda_pickedup() -> void:
	ofuda_count -= 1
	SignalBus.ofuda_count_changed.emit(ofuda_count)

func _on_ofuda_radius_mouse_entered() -> void:
	can_place = true

func _on_ofuda_radius_mouse_exited() -> void:
	can_place = false

func _on_player_hurt() -> void:
	player_health -= 1
