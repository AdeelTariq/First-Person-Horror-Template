extends Node


signal camera_lock_requested(enable: bool)
func request_camera_lock(enable: bool) -> void:
	camera_lock_requested.emit(enable)


signal added_to_inventory(resource: Resource)
func add_to_inventory(resource: Resource) -> void:
	added_to_inventory.emit(resource)
