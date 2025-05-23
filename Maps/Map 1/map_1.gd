class_name Map
extends Node2D

@export var is_tutorial: bool = false
@export var spawner_component: SpawnerComponent
@export var world_objects_node: Node2D
@export var world_boundaries: Array[SpawnerRect2D]
@export var book_ui: CanvasLayer

@onready var world_boundaries_group: Array[Node] = get_tree().get_nodes_in_group("world regions")

var ambient_audio_played: bool = false
var end_ui_audio_played: bool = false
var player_dead: bool = false

func _ready() -> void:
	Global.book_gone = false
	Global.scene_tree = get_tree()
	var scene_path = get_scene_file_path()
	
	$FadeRect/AnimationPlayer.play("fade_in")
	await get_tree().create_timer(1.0).timeout
	
	if scene_path == "res://Maps/Tutorial/tutorial_map.tscn":
		$HUD/Instructions/AnimationPlayer.play("fade_in")
		$HUD/Instructions.visible = true
	
	AudioManager.play_background_track1(randi_range(MusicResource.MusicType.BACKGROUND_AMBIENCE_TRACK_1, MusicResource.MusicType.BACKGROUND_AMBIENCE_TRACK_2))
	AudioManager.play_background_track2(MusicResource.MusicType.BACKGROUND_AMBIENCE_LOOP)
	
	if world_boundaries.is_empty() or len(world_boundaries_group) != len(world_boundaries):
		world_boundaries = []
		for world_region in world_boundaries_group:
			world_boundaries.append(world_region)
		Global.world_boundaries = world_boundaries
	
	if world_boundaries.is_empty():
		assert(false, "World boundaries array not found in root node.")
	
	Global.world_node = self
	SignalBus.player_dead.connect(_on_player_dead)
	if world_objects_node:
		Global.world_objects_node = world_objects_node
	else:
		world_objects_node = Node2D.new().instantiate()
		world_objects_node.y_sort_enabled = true
		Global.world_objects_node = world_objects_node
		add_child(world_objects_node)
	spawner_component.spawn_ghost()
	
	if not is_tutorial:
		spawner_component.spawn_mirror()

func _process(_delta: float) -> void:
	if Global.book_gone:
		book_ui.visible = false
	if Input.is_action_just_pressed("toggle_journal") and book_ui and not Global.book_gone:
		if not book_ui.visible:
			AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_OPEN)
		elif book_ui.visible:
			AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_CLOSE)
		book_ui.visible = !book_ui.visible
	elif Input.is_action_just_pressed("toggle_journal") and not book_ui and not Global.book_gone:
		assert(false, "Book UI CanvasLayer not found in root node.")
	
	if not ambient_audio_played and not player_dead:
		_rand_ambient_audio()
		ambient_audio_played = true
		await get_tree().create_timer(10).timeout
		ambient_audio_played = false

func _on_player_dead() -> void:
	player_dead = true
	
	$HUD/JumpScareLayer.visible = true
	AudioManager.play_sfx_global(SoundResource.SoundType.JUMPSCARE_SOUND)
	$HUD/JumpScareLayer/Flash/AnimationPlayer.play("flash")
	if Global.ghost_appearance == 0:
		$HUD/JumpScareLayer/LadyScare.visible = true
		$HUD/JumpScareLayer/LadyScare/AnimationPlayer.play("flash")
	elif Global.ghost_appearance == 1:
		$HUD/JumpScareLayer/BlueScare.visible = true
		$HUD/JumpScareLayer/BlueScare/AnimationPlayer.play("flash")
	else:
		$HUD/JumpScareLayer/ZombieScare.visible = true
		$HUD/JumpScareLayer/ZombieScare/AnimationPlayer.play("flash")
		
	
	await get_tree().create_timer(2.0).timeout
	
	if not end_ui_audio_played:
		end_ui_audio_played = true
		AudioManager.play_sfx_global(SoundResource.SoundType.GAME_END_UI)
	
	get_tree().change_scene_to_file("res://UI/Scenes/game_over.tscn")

func _rand_ambient_audio() -> void:
	if randf_range(0, 1) <= 0.5:
		await get_tree().create_timer(randf_range(4, 8)).timeout
		AudioManager.play_sfx_global(randi_range(SoundResource.SoundType.AMBIENT_KNOCK_1, SoundResource.SoundType.AMBIENT_HEX))
