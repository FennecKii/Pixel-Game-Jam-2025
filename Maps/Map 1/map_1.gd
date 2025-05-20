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
	Global.scene_tree = get_tree()
	
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
	if Input.is_action_just_pressed("toggle_journal") and book_ui:
		if not book_ui.visible:
			AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_OPEN)
		elif book_ui.visible:
			AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_CLOSE)
		book_ui.visible = !book_ui.visible
	elif Input.is_action_just_pressed("toggle_journal") and not book_ui:
		assert(false, "Book UI CanvasLayer not found in root node.")
	
	if not ambient_audio_played and not player_dead:
		_rand_ambient_audio()
		ambient_audio_played = true
		await get_tree().create_timer(10).timeout
		ambient_audio_played = false

func _on_player_dead() -> void:
	player_dead = true
	if not end_ui_audio_played:
		end_ui_audio_played = true
		AudioManager.play_sfx_global(SoundResource.SoundType.GAME_END_UI)
	get_tree().change_scene_to_file("res://UI/Scenes/game_over.tscn")

func _rand_ambient_audio() -> void:
	if randf_range(0, 1) <= 0.5:
		await get_tree().create_timer(randf_range(4, 8)).timeout
		AudioManager.play_sfx_global(randi_range(SoundResource.SoundType.AMBIENT_KNOCK_1, SoundResource.SoundType.AMBIENT_HEX))
