@tool
extends EditorPlugin

var license_editor: PackedScene = load(get_plugin_path() + "license_editor.tscn")

var context_menu_plugin: EditorContextMenuPlugin

func _enter_tree() -> void:
	add_tool_menu_item("Generate Credits", generate_credits)
	context_menu_plugin = LicenseMenu.new()
	var instance = license_editor.instantiate()
	instance.hide()
	add_child(instance)
	context_menu_plugin.dialog = instance
	add_context_menu_plugin(EditorContextMenuPlugin.ContextMenuSlot.CONTEXT_SLOT_FILESYSTEM_CREATE, context_menu_plugin)


func _exit_tree() -> void:
	remove_tool_menu_item("Generate Credits")
	remove_context_menu_plugin(context_menu_plugin)


func generate_credits() -> void:
	Generator.new().generate()



func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"
