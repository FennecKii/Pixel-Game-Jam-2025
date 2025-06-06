extends Node2D

@export var ghost_detection_component: GhostDetectionComponent
@export var display_item: bool = false
@export var held_item: bool = false

@onready var pickup_area: Area2D = $"Pickup Area"
@onready var pickup_collision: CollisionShape2D = $"Pickup Area/Pickup Collision"
@onready var ofuda_placed_label: Label = $"Ofuda Placed"
@onready var pickup_label: Label = %Pickup
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var ofuda_placed: bool = false
var can_pickup: bool = false
var ofuda_audio_played: bool = false
var ofuda_count_lable: Label
var ofuda_count: int = 0
var ofuda_pickup_audio_played: bool = false

func _ready() -> void:
	if not ghost_detection_component:
		assert(false, "Ghost Detection Component not found.")
	
	SignalBus.ofuda_placed.connect(_on_ofuda_placed)
	SignalBus.ofuda_count_changed.connect(_on_ofuda_count_changed)
	if display_item:
		ofuda_count_lable = $Labels/Value
	
	if not ofuda_placed or display_item:
		pickup_area.process_mode = Node.PROCESS_MODE_DISABLED
		pickup_collision.visible = false
		ghost_detection_component.process_mode = Node.PROCESS_MODE_DISABLED
		ghost_detection_component.visible = false
		ghost_detection_component.collision.visible = false

func _process(_delta: float) -> void:
	_update_ofuda_label()
	
	if not ofuda_pickup_audio_played:
		_ofuda_pickup()
	
	if ofuda_count != 0 and not display_item:
		ofuda_placed = true
	
	if ofuda_placed and not display_item:
		pickup_area.process_mode = Node.PROCESS_MODE_INHERIT
		pickup_collision.visible = true
		ghost_detection_component.process_mode = Node.PROCESS_MODE_INHERIT
		ghost_detection_component.visible = true
		ghost_detection_component.collision.visible = true
		_update_item_response()
	
	if can_pickup:
		pickup_label.visible = true
	else:
		pickup_label.visible = false

func _update_ofuda_label() -> void:
	if ofuda_count_lable != null:
		ofuda_count_lable.text = str(2-ofuda_count)
		ofuda_count_lable.add_theme_color_override("font_color", Color.LIME_GREEN) 
	if ofuda_count_lable != null and ofuda_count == 2:
		ofuda_count_lable.add_theme_color_override("font_color", Color.RED) 

func _on_ofuda_placed() -> void:
	if display_item:
		return
	
	if ofuda_placed or held_item:
		return
	
	ofuda_placed_label.visible = true
	await get_tree().create_timer(1).timeout
	ofuda_placed_label.visible = false

func _on_ofuda_count_changed(count: int) -> void:
	if display_item:
		ofuda_count = count

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		can_pickup = true

func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		can_pickup = false

func _ofuda_pickup() -> void:
	if can_pickup and Input.is_action_just_pressed("Interact"):
		ofuda_pickup_audio_played = true
		AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.ITEM_PICKUP)
		SignalBus.ofuda_pickedup.emit()
		queue_free()

func _update_item_response() -> void:
	if not ghost_detection_component.ghost_detected:
		return
	elif ghost_detection_component.ghost_detected and ghost_detection_component.ghost_type == Global.GhostNames.YUKIONNA:
		if randf_range(0, 1) <= 0.5:
			var anim_array: Array[String] = ["burn", "glow"]
			var rand_anim: String = anim_array.pick_random()
			animation_player.play(rand_anim)
			if not ofuda_audio_played and rand_anim == "burn":
				AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.ITEM_ODFUA_BURN)
				ofuda_audio_played = true
			elif not ofuda_audio_played and rand_anim == "glow":
				AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.ITEM_ODFUA_GLOW)
				ofuda_audio_played = true
			pickup_area.process_mode = Node.PROCESS_MODE_DISABLED
			pickup_collision.visible = false
			await animation_player.animation_finished
			queue_free()
	elif ghost_detection_component.ghost_detected and ghost_detection_component.ghost_type == Global.GhostNames.ONRYO:
		if randf_range(0, 1) <= 0.5:
			animation_player.play("glow")
			if not ofuda_audio_played:
				AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.ITEM_ODFUA_GLOW)
				ofuda_audio_played = true
			pickup_area.process_mode = Node.PROCESS_MODE_DISABLED
			pickup_collision.visible = false
			await animation_player.animation_finished
			queue_free()
	elif ghost_detection_component.ghost_detected and ghost_detection_component.ghost_type == Global.GhostNames.JIKININKI:
		if randf_range(0, 1) <= 0.5:
			animation_player.play("burn")
			if not ofuda_audio_played:
				AudioManager.play_sfx_at_location(global_position, SoundResource.SoundType.ITEM_ODFUA_BURN)
				ofuda_audio_played = true
			pickup_area.process_mode = Node.PROCESS_MODE_DISABLED
			pickup_collision.visible = false
			await animation_player.animation_finished
			queue_free()
