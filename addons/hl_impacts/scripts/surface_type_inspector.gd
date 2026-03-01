class_name SurfaceTypeInspector extends EditorInspectorPlugin

const PROPERTY_NAME := "surface_type"

var mgr_path: String

func _init(path: String) -> void:
	self.mgr_path = path


func _can_handle(object):
	return object is PhysicsBody3D or (object is CSGShape3D and object.use_collision)


func _parse_begin(object):
	var value = "default"
	if object.has_meta(PROPERTY_NAME):
		value = object.get_meta(PROPERTY_NAME)

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
		object.set_meta(PROPERTY_NAME, field.get_item_text(index))
		object.property_list_changed_notify()
	)

	add_custom_control(field)
