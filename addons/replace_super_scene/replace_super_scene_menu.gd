@tool
class_name ReplaceSuperSceneMenu
extends EditorContextMenuPlugin

var _dialog: FileDialog
var _replace_callback: Callable


func setup(dialog: FileDialog, replace_callback: Callable) -> void:
	_dialog = dialog
	_replace_callback = replace_callback


func _popup_menu(_paths: PackedStringArray) -> void:
	if _get_selected_instances().is_empty():
		return
	var icon: Texture2D = EditorInterface.get_base_control().get_theme_icon("PackedScene", "EditorIcons")
	add_context_menu_item("Replace Super Scene...", _on_replace_super_scene, icon)


func _on_replace_super_scene(nodes: Array) -> void:
	var instances: Array[Node] = []
	for item: Variant in nodes:
		if item is Node:
			var node: Node = item
			if not node.scene_file_path.is_empty():
				instances.append(node)

	if instances.is_empty():
		instances = _get_selected_instances()
	if instances.is_empty():
		return

	_dialog.current_dir = instances[0].scene_file_path.get_base_dir()
	_dialog.popup_centered_ratio(0.6)
	var scene_path: String = await _dialog.file_selected
	if scene_path.is_empty():
		return

	var still_valid: Array[Node] = []
	for node: Node in instances:
		if is_instance_valid(node):
			still_valid.append(node)
	if still_valid.is_empty():
		return

	_replace_callback.call(still_valid, scene_path)


func _get_selected_instances() -> Array[Node]:
	var instances: Array[Node] = []
	var selection: EditorSelection = EditorInterface.get_selection()
	for node: Node in selection.get_top_selected_nodes():
		if not node.scene_file_path.is_empty():
			instances.append(node)
	return instances
