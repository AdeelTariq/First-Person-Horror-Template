@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("GameStateManager", get_plugin_path() + "game_state_mgr.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("GameStateManager")


func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"
