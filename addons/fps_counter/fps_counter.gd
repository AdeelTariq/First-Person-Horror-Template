class_name FPSCounter extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	text = str(Engine.get_frames_per_second())
