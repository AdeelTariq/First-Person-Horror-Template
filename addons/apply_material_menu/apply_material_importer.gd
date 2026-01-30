class_name ApplyMaterialImporter extends EditorScenePostImportPlugin


var new_mat_store: Dictionary[String, ShaderMaterial] = {}

func _get_name() -> String:
	return "ApplyMaterialImporter"

# Shown in Import dock as an option
func _get_import_options(path: String) -> void:
	if not path.ends_with(".glb") and not path.ends_with(".gltf") \
	   and not path.ends_with(".fbx") and not path.ends_with(".blend"):
		# skip unsupported types
		return
	add_import_option(
		"apply_material/enabled", false
	)
	add_import_option_advanced(Variant.Type.TYPE_STRING, "apply_material/material_path", "", PROPERTY_HINT_FILE_PATH)


# Called after Godot imports a model
func _post_process(scene: Node) -> void:
	if not get_option_value("apply_material/enabled"):
		return

	var material_path := get_option_value("apply_material/material_path")
	if material_path == "":
		printerr("ApplyMaterialImporter: No material path set.")
		return

	var material := load(material_path)
	if material == null:
		printerr("ApplyMaterialImporter: Failed to load material at: ", material_path)
		return

	new_mat_store = {}
	_apply_material_to_scene(scene, material)


# ---------------------------------------------------------
# Helpers
# ---------------------------------------------------------
func _apply_material_to_scene(node: Node, material: ShaderMaterial) -> void:
	if node is MeshInstance3D:
		_apply_material_to_mesh(node, material)

	for child in node.get_children():
		_apply_material_to_scene(child, material)


func _apply_material_to_mesh(mesh_instance: MeshInstance3D, material: ShaderMaterial) -> void:
	var mesh := mesh_instance.mesh
	if mesh == null:
		return


	for i in mesh.get_surface_count():
		var original_mat := mesh.surface_get_material(i)
		
		var original_mat_key = str(original_mat)
		var material_already_exists: bool = new_mat_store.has(original_mat_key)
		var new_mat = new_mat_store[original_mat_key] if material_already_exists else material.duplicate_deep()
		new_mat_store[original_mat_key] = new_mat
		
		if original_mat and not material_already_exists:
			_preserve_material_data(original_mat, new_mat)
		

		mesh.surface_set_material(i, new_mat)


# ------------------------------------------------------------
# Preserve material values
# ------------------------------------------------------------

func _preserve_material_data(from_mat: Material, to_mat: ShaderMaterial) -> void:
	if from_mat is StandardMaterial3D:
		_copy_standard_material(from_mat, to_mat)
	elif from_mat is ShaderMaterial:
		_copy_material_parameters(from_mat, to_mat)


func _copy_standard_material(std: StandardMaterial3D, sm: ShaderMaterial) -> void:
	# Maps StandardMaterial3D fields to material uniform names
	var mapping := {
		"albedo_color": "albedo_color",
		"albedo_texture": "albedo_texture",
		"metallic": "metallic",
		"metallic_texture": "metallic_texture",
		"roughness": "roughness",
		"roughness_texture": "roughness_texture",
		"normal_texture": "normal_texture",
		"ao_texture": "ao_texture",
		"emission": "emission_color",
		"emission_texture": "emission_texture"
	}
	
	for std_key in mapping.keys():
		if std.get(std_key) == null:
			continue
		
		var value = std.get(std_key)
		var material_uniform = mapping[std_key]

		sm.set_shader_parameter(material_uniform, value)


func _copy_material_parameters(from_material_mat: ShaderMaterial, to_material_mat: ShaderMaterial) -> void:
	# Maps StandardMaterial3D fields to material uniform names
	var mapping := {
		"albedo_color": "albedo_color",
		"albedo_texture": "albedo_texture",
		"metallic": "metallic",
		"metallic_texture": "metallic_texture",
		"roughness": "roughness",
		"roughness_texture": "roughness_texture",
		"normal_texture": "normal_texture",
		"ao_texture": "ao_texture",
		"emission": "emission_color",
		"emission_texture": "emission_texture"
	}

	for std_key in mapping.keys():
		if from_material_mat.get_shader_parameter(std_key) == null:
			continue
		
		var value = from_material_mat.get_shader_parameter(std_key)
		var material_uniform = mapping[std_key]

		to_material_mat.set_shader_parameter(material_uniform, value)
