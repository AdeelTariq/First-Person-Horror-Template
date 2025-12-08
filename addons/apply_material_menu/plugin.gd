@tool
extends EditorPlugin

var plugin: ApplyMaterialMenu
var import_plugin: ApplyMaterialImporter

func _enter_tree():
	plugin = ApplyMaterialMenu.new()
	var file_dialog = FileDialog.new()
	file_dialog.exclusive = false
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.tres ; Material files")
	add_child(file_dialog)
	file_dialog.popup_centered()
	file_dialog.hide()
	plugin.dialog = file_dialog
	add_context_menu_plugin(EditorContextMenuPlugin.ContextMenuSlot.CONTEXT_SLOT_FILESYSTEM, plugin)
	import_plugin = ApplyMaterialImporter.new()
	add_scene_post_import_plugin(import_plugin)

func _exit_tree():
	remove_child(plugin.dialog)
	remove_context_menu_plugin(plugin)
	remove_scene_post_import_plugin(import_plugin)
