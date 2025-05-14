extends Node

@onready var player_node: Node2D
@onready var ofuda: PackedScene = preload("res://Items/Ofuda/ofuda.tscn")
@onready var yuki_onna: PackedScene = preload("res://Ghosts/Yuki-Onna/yuki_onna.tscn")
@onready var onryo: PackedScene = preload("res://Ghosts/Onryo/onryo.tscn")
@onready var jikininki: PackedScene = preload("res://Ghosts/Jikininki/jikininki.tscn")

@onready var ghost_scene_array: Array[PackedScene] = [
	yuki_onna,
	onryo,
	jikininki
]

var ghost_detected: bool = false
var ghost_direction: Vector2
var player_position: Vector2
var ghost_position: Vector2
