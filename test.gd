@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var velocity = Vector3(-10, 0, 0)
	print(velocity.dot(Vector3(-1, 0, 0)))
