class_name ApplyMaterialMenu extends EditorContextMenuPlugin

var icon: Texture2D = load(get_plugin_path() + "ShaderMaterial.svg")

var dialog: FileDialog


func _popup_menu(paths: PackedStringArray) -> void:
	var has_3d_file: bool = false
	for path in paths:
		has_3d_file = has_3d_file or path.ends_with(".glb") or path.ends_with(".gltf") or path.ends_with(".blend") or path.ends_with(".fbx")
	
	if has_3d_file:
		add_context_menu_item("Apply Material To Model", select_material, icon)


func select_material(paths: PackedStringArray) -> void:
	dialog.show()
	_on_material_selected(await dialog.file_selected, paths)


func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"


func _on_material_selected(material_path: String, three_d_paths: PackedStringArray):
	set_import_script_for_files(three_d_paths, material_path)


func set_import_script_for_files(model_paths: PackedStringArray, material_path: String) -> void:
	# validate
	if not ResourceLoader.exists(material_path):
		push_error("Material not found: %s" % material_path)
		return

	var fs := EditorInterface.get_resource_filesystem() # EditorFileSystem
	var reimport_list := PackedStringArray()

	for model_path in model_paths:
		if not model_path.ends_with(".glb") and not model_path.ends_with(".gltf") \
		   and not model_path.ends_with(".fbx") and not model_path.ends_with(".blend"):
			# skip unsupported types
			continue

		var import_path := "%s.import" % model_path
		# If .import file doesn't exist yet, trigger an update/scan so Godot generates it first.
		if not FileAccess.file_exists(import_path):
			# ask the editor to scan/update so the import file appears
			fs.update_file(model_path)
			# small sleep loop to wait a bit for the editor to create .import (blocking is ok in editor plugin)
			var t := 0.0
			while not FileAccess.file_exists(import_path) and t < 1.0:
				OS.delay_msec(50)
				t += 0.05
			if not FileAccess.file_exists(import_path):
				push_error("Missing .import for %s" % model_path)
				continue

		# read the .import file as text
		var txt := ""
		var f := FileAccess.open(import_path, FileAccess.READ)
		if f:
			txt = f.get_as_text()
			f.close()
		else:
			push_error("Failed to open %s" % import_path)
			continue

		# Remove existing apply_material* occurrences first
		var new_txt := []
		for line in txt.split("\n"):
			# remove any apply_material param nested keys (defensive)
			if line.strip_edges().begins_with("apply_material/"):
				continue
			new_txt.append(line)
		# Append our import_script entries at end (Godot accepts them)
		new_txt.append('apply_material/enabled=true')
		# store material path as a custom option; the exact naming in import UI can vary, but import script can receive options table.
		# We'll write a custom_options entry that some importers accept; import script can read options param named "material_path".
		new_txt.append('apply_material/material_path="%s"' % material_path)

		var out_text := String("\n").join(new_txt)

		# write the modified .import
		var w := FileAccess.open(import_path, FileAccess.WRITE)
		if not w:
			push_error("Failed to write %s" % import_path)
			continue
		w.store_string(out_text)
		w.close()

		reimport_list.append(model_path)

	# reimport changed files
	if reimport_list.size() > 0:
		# This will block until import finishes
		fs.reimport_files(reimport_list)
		# Refresh FS so editor shows changes
		fs.scan()
