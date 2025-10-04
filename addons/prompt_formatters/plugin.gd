@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("InputIconMapperGlobal", get_plugin_path() + "kenneys/input_icon_mapper.tscn")
	add_tool_menu_item("Add Input Prompt Icons", open_input_icons_dialog)


func _exit_tree() -> void:
	remove_autoload_singleton("InputIconMapperGlobal")
	remove_tool_menu_item("Add Input Prompt Icons")


func open_input_icons_dialog() -> void:
	var input_icons_scene : PackedScene = load(get_plugin_path() + "kenneys/maaacks_icons_installer/kenney_input_prompts_installer.tscn")
	var input_icons_instance = input_icons_scene.instantiate()
	add_child(input_icons_instance)


func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"


func get_copy_path() -> String:
	var copy_path = ProjectSettings.get_setting(get_plugin_path() + "icons")
	if not copy_path.ends_with("/"):
		copy_path += "/"
	return copy_path
