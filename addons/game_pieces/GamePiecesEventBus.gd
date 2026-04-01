extends Node


signal camera_lock_requested(enable: bool)
func request_camera_lock(enable: bool) -> void:
	camera_lock_requested.emit(enable)


signal controls_lock_requested(enable: bool)
func request_control_lock(enable: bool) -> void:
	controls_lock_requested.emit(enable)


signal added_to_inventory(resource: Resource)
func add_to_inventory(resource: Resource) -> void:
	added_to_inventory.emit(resource)


signal gameplay_message(text: String)
func show_gameplay_message(text: String) -> void:
	gameplay_message.emit(text)
