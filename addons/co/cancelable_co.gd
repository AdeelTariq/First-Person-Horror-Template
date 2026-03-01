class_name CancelableCo
extends Co


func run(host: Node) -> void:

	if not host:
		host = Engine.get_main_loop().root
	host.add_child(self)
	await _routine()
	await _cleanup()
	get_parent().remove_child(self)
	queue_free()


func cancel() -> void:

	_cleanup()
	if is_inside_tree():
		get_parent().remove_child(self)
	queue_free()


# VIRTUAL
func _routine() -> void:

	await one_frame()


# VIRTUAL
func _cleanup() -> void:

	pass
