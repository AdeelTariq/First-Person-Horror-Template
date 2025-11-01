class_name LicenseMenu extends EditorContextMenuPlugin

var icon: Texture2D = load(get_plugin_path() + "license.svg")
var dialog: LicenseEditor

func _popup_menu(paths: PackedStringArray) -> void:
	if paths.size() == 1:
		add_context_menu_item("License File", create_license, icon)


func create_license(paths: PackedStringArray) -> void:
	dialog.show_dialog(paths[0])


func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"
