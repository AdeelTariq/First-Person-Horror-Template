@tool
extends EditorPlugin

var _menu: ReplaceSuperSceneMenu
var _dialog: FileDialog


func _enter_tree() -> void:
	_dialog = FileDialog.new()
	_dialog.exclusive = false
	_dialog.access = FileDialog.ACCESS_RESOURCES
	_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_dialog.title = "Select Replacement Scene"
	_dialog.add_filter("*.tscn, *.scn ; Scenes")
	add_child(_dialog)
	_dialog.hide()

	_menu = ReplaceSuperSceneMenu.new()
	_menu.setup(_dialog, replace_super_scenes)
	add_context_menu_plugin(EditorContextMenuPlugin.ContextMenuSlot.CONTEXT_SLOT_SCENE_TREE, _menu)


func _exit_tree() -> void:
	if _menu:
		remove_context_menu_plugin(_menu)
		_menu = null
	if _dialog:
		_dialog.queue_free()
		_dialog = null


func replace_super_scenes(nodes: Array[Node], scene_path: String) -> void:
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_error("Replace Super Scene: scene not found: %s" % scene_path)
		return

	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		push_error("Replace Super Scene: failed to load PackedScene: %s" % scene_path)
		return

	var edited_root: Node = EditorInterface.get_edited_scene_root()
	if edited_root == null:
		push_error("Replace Super Scene: no edited scene")
		return

	if edited_root.scene_file_path == scene_path:
		push_error("Replace Super Scene: cannot instance the currently edited scene")
		return

	var replacements: Array[Dictionary] = []
	for old_node: Node in nodes:
		if not is_instance_valid(old_node):
			continue
		if old_node.scene_file_path.is_empty():
			continue
		if old_node.scene_file_path == scene_path:
			continue
		if old_node == edited_root:
			push_warning("Replace Super Scene: skipping edited scene root '%s'" % old_node.name)
			continue

		var new_node: Node = _build_replacement(old_node, packed)
		if new_node == null:
			continue
		replacements.append({
			"old": old_node,
			"new": new_node,
			"editable": edited_root.is_editable_instance(old_node),
		})

	if replacements.is_empty():
		return

	var undo_redo: EditorUndoRedoManager = get_undo_redo()
	undo_redo.create_action("Replace Super Scene", UndoRedo.MERGE_DISABLE, edited_root)
	for entry: Dictionary in replacements:
		var old_node: Node = entry["old"]
		var new_node: Node = entry["new"]
		var make_editable: bool = entry["editable"]
		undo_redo.add_do_method(self, "_swap_instance", old_node, new_node, make_editable)
		undo_redo.add_undo_method(self, "_swap_instance", new_node, old_node, make_editable)
		undo_redo.add_do_reference(new_node)
		undo_redo.add_undo_reference(old_node)
	undo_redo.commit_action()


func _build_replacement(old_node: Node, packed: PackedScene) -> Node:
	var baseline_packed: PackedScene = load(old_node.scene_file_path) as PackedScene
	if baseline_packed == null:
		push_error("Replace Super Scene: failed to load current scene: %s" % old_node.scene_file_path)
		return null

	var baseline: Node = baseline_packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var new_node: Node = packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	# Name is applied during swap after the old node is removed, to avoid Godot's
	# automatic sibling rename (Name -> Name2).
	_copy_property_diffs(old_node, baseline, new_node)
	# Remember direct children that don't exist in the old packed scene so swap
	# can transfer them even if owner isn't the edited scene root for some reason.
	var extra_names: PackedStringArray = PackedStringArray()
	for child: Node in old_node.get_children():
		if baseline.get_node_or_null(NodePath(child.name)) == null:
			extra_names.append(String(child.name))
	new_node.set_meta("_rss_extra_child_names", extra_names)
	baseline.free()
	return new_node


func _copy_property_diffs(from_node: Object, baseline: Object, to_node: Object) -> void:
	for prop: Dictionary in from_node.get_property_list():
		if not (prop.usage & PROPERTY_USAGE_STORAGE):
			continue
		var prop_name: String = prop.name
		if prop_name in ["owner", "scene_file_path", "name", "multiplayer"]:
			continue
		if not (prop_name in to_node):
			continue
		if not (prop_name in baseline):
			continue

		var value: Variant = from_node.get(prop_name)
		var baseline_value: Variant = baseline.get(prop_name)
		if value == baseline_value:
			continue
		to_node.set(prop_name, value)


func _swap_instance(remove_node: Node, add_node: Node, make_editable: bool) -> void:
	if not is_instance_valid(remove_node) or not is_instance_valid(add_node):
		return

	var parent: Node = remove_node.get_parent()
	if parent == null:
		return

	var edited_root: Node = EditorInterface.get_edited_scene_root()
	if edited_root == null:
		return

	var index: int = remove_node.get_index()
	var node_owner: Node = remove_node.owner
	var desired_name: String = String(remove_node.name)

	# Remove first so the replacement can keep the original name.
	parent.remove_child(remove_node)
	add_node.name = desired_name
	parent.add_child(add_node)
	parent.move_child(add_node, index)
	add_node.owner = node_owner

	# Transfer after the replacement is in the tree so instance setup can't
	# wipe children that were attached beforehand.
	_transfer_local_edits(remove_node, add_node, edited_root)

	# Preserve the original editable-children flag only — don't enable it just
	# because local children were moved (those already show without it).
	if make_editable:
		edited_root.set_editable_instance(add_node, true)


func _transfer_local_edits(from_node: Node, to_node: Node, edited_root: Node) -> bool:
	var transferred: bool = false
	var extra_names: PackedStringArray = PackedStringArray()
	if to_node.has_meta("_rss_extra_child_names"):
		extra_names = to_node.get_meta("_rss_extra_child_names")
		to_node.remove_meta("_rss_extra_child_names")

	# Snapshot because we mutate the child list while iterating.
	var children: Array[Node] = []
	children.assign(from_node.get_children())

	for child: Node in children:
		var is_extra: bool = extra_names.has(String(child.name))
		if child.owner == edited_root or is_extra:
			_move_local_child(from_node, to_node, child, edited_root)
			transferred = true
			continue

		var matching: Node = to_node.get_node_or_null(NodePath(child.name))
		if matching != null:
			if _transfer_local_edits(child, matching, edited_root):
				matching.owner = edited_root
				transferred = true

	return transferred


func _move_local_child(from_parent: Node, to_parent: Node, child: Node, edited_root: Node) -> void:
	var child_index: int = child.get_index()
	from_parent.remove_child(child)

	var matching: Node = to_parent.get_node_or_null(NodePath(child.name))
	if matching != null and matching != child:
		# Park the replacement's packed child on the removed node so undo can
		# swap them back by the same local-edit transfer rules.
		var matching_index: int = matching.get_index()
		to_parent.remove_child(matching)
		from_parent.add_child(matching)
		from_parent.move_child(matching, mini(child_index, from_parent.get_child_count()))
		matching.owner = edited_root

		to_parent.add_child(child)
		to_parent.move_child(child, mini(matching_index, to_parent.get_child_count()))
	else:
		to_parent.add_child(child)
		to_parent.move_child(child, mini(child_index, to_parent.get_child_count()))

	child.owner = edited_root
