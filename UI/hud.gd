extends CanvasLayer

@onready var compass: Node2D = %Compass
@onready var bell_cooldown_label: Label = $Control/Items/Bell/Labels/Value

func _ready() -> void:
	Global.bell_cooldown_label = bell_cooldown_label
