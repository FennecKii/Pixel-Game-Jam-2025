class_name GhostDetectionComponent
extends Area2D

@onready var collision: CollisionShape2D = %"Detection Collision"
@onready var ghost_detected: bool = false
@onready var ghost_type: int

func _on_ghost_detection_component_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ghost"):
		ghost_detected = true
		ghost_type = body.ghost_type

func _on_ghost_detection_component_body_exited(body: Node2D) -> void:
	if body.is_in_group("Ghost"):
		ghost_detected = false
