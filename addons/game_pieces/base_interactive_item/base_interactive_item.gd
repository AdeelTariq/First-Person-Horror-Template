@abstract 
class_name BaseInteractiveItem extends Area3D

var _materials: Array[Material] = []

## Needed for correct placement of items on the ground when dropped
@abstract 
func get_aabb() -> AABB

func _prepare_materials(mesh_instance: MeshInstance3D) -> void:
	var mesh := mesh_instance.mesh
	if mesh == null:
		return

	var global_override := mesh_instance.material_override

	for i: int in range(mesh.get_surface_count()):
		var mat: Material = null

		if global_override:
			mat = global_override
		else:
			mat = mesh_instance.get_surface_override_material(i)
			if mat == null:
				mat = mesh.surface_get_material(i)
		if mat and mat not in _materials:
			mat = mat.duplicate()
			_materials.append(mat)
		mesh_instance.set_surface_override_material(i, mat)


func _set_equipped(value: bool) -> void:
	for mat: Material in _materials:
		if mat is ShaderMaterial:
			mat.set_shader_parameter("equipped", value)
