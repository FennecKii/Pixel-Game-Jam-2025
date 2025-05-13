extends CharacterBody2D

@onready var animated_sprite_2d:  AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hud: Control = $Camera2D/HUD
@onready var bell: Node2D = %Bell
@onready var ofuda: Node2D = %Ofuda
@onready var ofuda_outline: Sprite2D = %"Ofuda Outline"
@onready var root_node: Node2D = get_tree().get_root().get_node("Map")

var SPEED: float = 10000
var previous_velocity: Vector2
var bell_equiped: bool = false
var ofuda_equiped: bool = false
var bell_volume: float
var ofuda_count: int = 0

func _ready() -> void:
	Global.player_node = self
	SignalBus.ofuda_pickedup.connect(_on_ofuda_pickedup)
	animation_tree.active = true
	hud.position = get_viewport_rect().size * -1 / 2

func _process(_delta: float) -> void:
	Global.player_position = global_position
	
	_update_item_states()
	
	_handle_item_input()

func _physics_process(delta: float) -> void:
	
	var direction: Vector2 = Input.get_vector("Left", "Right", "Up", "Down").normalized()
	
	if direction:
		velocity = direction * SPEED * delta
	else:
		velocity = Vector2.ZERO
	
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

func _update_item_states() -> void:
	if ofuda_count == 2:
		ofuda_outline.self_modulate.b = 0
		ofuda_outline.self_modulate.g = 0
	
	bell_equiped = bell.visible
	ofuda_equiped = ofuda.visible
	ofuda_outline.global_position = get_global_mouse_position()

func _handle_item_input() -> void:
	# Equip or Switch Items
	if Input.is_action_just_pressed("Equip Bell") and not bell_equiped:
		bell.visible = true
		ofuda.visible = false
		ofuda_outline.visible = false
	elif Input.is_action_just_pressed("Equip Ofuda") and not ofuda_equiped:
		ofuda.visible = true
		bell.visible = false
		ofuda_outline.visible = true
	
	# Unequip Items
	if Input.is_action_just_pressed("Equip Bell") and bell_equiped:
		bell.visible = false
	elif Input.is_action_just_pressed("Equip Ofuda") and ofuda_equiped:
		ofuda.visible = false
		ofuda_outline.visible = false
	
	# Use Items
	if Input.is_action_just_pressed("Use Item") and bell_equiped:
		SignalBus.bell_rang.emit(bell_volume)
	elif Input.is_action_just_pressed("Use Item") and ofuda_equiped:
		if ofuda_count < 2:
			ofuda_count += 1
			SignalBus.ofuda_placed.emit()
			SignalBus.ofuda_count_changed.emit(ofuda_count)
			_place_ofuda(get_global_mouse_position())

func _place_ofuda(map_position: Vector2) -> void:
	var ofuda_instance = Global.ofuda.instantiate()
	ofuda_instance.global_position = map_position
	ofuda_instance.ofuda_placed = true
	if root_node != null:
		root_node.add_child(ofuda_instance)

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ghost"):
		Global.ghost_detected = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("Ghost"):
		Global.ghost_detected = false

func _on_ofuda_pickedup() -> void:
	ofuda_count -= 1
	SignalBus.ofuda_count_changed.emit(ofuda_count)
