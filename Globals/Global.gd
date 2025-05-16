extends Node

enum GhostNames {YUKIONNA, ONRYO, JIKININKI}

@onready var world_node: Node2D
@onready var player_node: Node2D
@onready var yuki_onna_node: Node2D
@onready var onryo_node: Node2D
@onready var jikininki_node: Node2D
@onready var world_objects_node: Node2D
@onready var ofuda_scene: PackedScene = preload("res://Items/Ofuda/ofuda.tscn")
@onready var yuki_onna_scene: PackedScene = preload("res://Ghosts/Yuki-Onna/yuki_onna.tscn")
@onready var onryo_scene: PackedScene = preload("res://Ghosts/Onryo/onryo.tscn")
@onready var jikininki_scene: PackedScene = preload("res://Ghosts/Jikininki/jikininki.tscn")

@onready var ghost_scene_array: Array[PackedScene] = [
	yuki_onna_scene,
	onryo_scene,
	jikininki_scene
]

var spawn_regions: Array[SpawnerRect2D]
var world_boundary_region: SpawnerRect2D
var player_max_health: int = 1
var current_ghost: PackedScene
var player_ghost_detected: bool = false
var player_position: Vector2
var ghost_position: Vector2
var bell_equipped: bool = false
var ofuda_equipped: bool = false
