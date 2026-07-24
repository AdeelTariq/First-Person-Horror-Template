@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("EventBus", get_plugin_path() + "event_bus.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("EventBus")


func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"
