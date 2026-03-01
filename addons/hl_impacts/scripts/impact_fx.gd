extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var signals: Array[Signal] = []
	for child: Node in get_children():
		if child is not GPUParticles3D: continue
		child.restart()
		signals.append(child.finished)
	await co.all(signals)
	queue_free()
