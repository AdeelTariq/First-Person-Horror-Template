extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale += Vector3(randf_range(-0.1, 0.1), 0.0, randf_range(-0.1, 0.1))
