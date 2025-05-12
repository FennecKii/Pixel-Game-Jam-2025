extends Node

@onready var yuki_onna: PackedScene = preload("res://Ghosts/Yuki-Onna/yuki_onna.tscn")

@onready var ghost_scene_array: Array[PackedScene] = [
	yuki_onna,
	
]

var ghost_detected: bool = false
var ghost_direction: Vector2
var player_position: Vector2
var ghost_position: Vector2
