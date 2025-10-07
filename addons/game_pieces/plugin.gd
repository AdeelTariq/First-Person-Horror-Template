@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("GamePiecesEventBus", get_plugin_path() + "GamePiecesEventBus.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("GamePiecesEventBus")


func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"
