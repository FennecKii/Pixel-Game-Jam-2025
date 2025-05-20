extends Node

enum GhostNames {YUKIONNA, ONRYO, JIKININKI}
enum GhostAppearance {DEFAULT, BLUE, UNDEAD}
enum SpriteDirection {UNKNOWN, DOWN, UP, SIDE}

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Nodes
@onready var world_node: Node2D
@onready var player_node: Node2D
@onready var ghost_node: Node2D
@onready var world_objects_node: Node2D
@onready var bell_cooldown_label: Label

# Preload Scenes
@onready var ofuda_scene: PackedScene = preload("res://Items/Ofuda/ofuda.tscn")
@onready var ghost_scene: PackedScene = preload("res://Ghosts/ghost.tscn")
@onready var mirror_scene: PackedScene = preload("res://Objects/Mirror/mirror.tscn")

# Global variables
var spawn_regions: Array[SpawnerRect2D]
var world_boundaries: Array[SpawnerRect2D]
var player_max_health: int = 1
var current_ghost: int
var ghost_detectable: bool = false
var player_ghost_detected: bool = false
var player_position: Vector2
var ghost_position: Vector2
var bell_equipped: bool = false
var ofuda_equipped: bool = false
var player_house_entered: bool = false
var timer_alert_zone: bool = false
var ghost_appearance: int
var scene_tree: SceneTree
var wincount: int = 0
