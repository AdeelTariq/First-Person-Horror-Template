class_name SurfaceTypeInspector extends EditorInspectorPlugin

const PROPERTY_NAME := "surface_type"

var mgr_path: String

func _init(path: String) -> void:
	self.mgr_path = path


func _can_handle(object):
	if _is_supported_type(object):
		return true
	var objects = EditorInterface.get_selection().get_selected_nodes()
	return objects.all(func (o) -> bool: return _is_supported_type(o))


func _is_supported_type(object) -> bool:
	return object is PhysicsBody3D or (object is CSGShape3D and object.use_collision)


func _parse_begin(object):
	var value = "default"
	if _is_supported_type(object):
		if object.has_meta(PROPERTY_NAME):
			value = object.get_meta(PROPERTY_NAME)
	else:
		var objects = EditorInterface.get_selection().get_selected_nodes()
		var other_surfaces: Array = objects.map(
			func (o) -> String: 
				if o.has_meta(PROPERTY_NAME):
					return o.get_meta(PROPERTY_NAME)
				else:
					return "default"
		)
		if not other_surfaces.is_empty() and other_surfaces.count(other_surfaces[0]) == objects.size():
			value = other_surfaces[0]

	var scene = load(mgr_path)
	var mgr: ImpactManager = scene.instantiate()
	var surfaces: PackedStringArray = mgr.get_surface_names()
	
	var label: Label = Label.new()
	label.text = "Surface Type"
	add_custom_control(label)
	
	var field = OptionButton.new()
	var i: int = 0
	for surface: String in surfaces:
		field.add_item(surface)
		if surface == value:
			field.select(i)
		i += 1
	
	field.item_selected.connect(func(index):
		_set_object_value(object, field.get_item_text(index))
	)

	add_custom_control(field)


func _set_object_value(object, value):
	if _is_supported_type(object):
		object.set_meta(PROPERTY_NAME, value)
		object.notify_property_list_changed()
	else:
		var objects = EditorInterface.get_selection().get_selected_nodes()
		for o in objects:
			_set_object_value(o, value)
