extends Node


signal camera_lock_requested(enable: bool)
func request_camera_lock(enable: bool) -> void:
	camera_lock_requested.emit(enable)
