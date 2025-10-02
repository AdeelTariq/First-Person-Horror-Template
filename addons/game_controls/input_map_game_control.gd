@tool
class_name InputMapGameControl extends GameControl

enum Type {Default, MultiDimensional}

@export var type: Type = Type.Default:
	set(value):
		type = value
		notify_property_list_changed()
@export var action: StringName

@export var negative_x: StringName
@export var positive_x: StringName
@export var negative_y: StringName
@export var positive_y: StringName

@onready var _formatter: GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts()

func value() -> float:
	if type == Type.Default:
		return Input.get_action_strength(action)
	else:
		return Input.get_axis(negative_x, positive_x)

func value_axis_2d() -> Vector2:
	return Input.get_vector(negative_x, positive_x, negative_y, positive_y)

func value_axis_3d() -> Vector3:
	var dir: Vector2 = Input.get_vector(negative_x, positive_x, negative_y, positive_y)
	return Vector3(dir.x, 0.0, dir.y)

func display_text_async() -> String:
	if type == Type.Default:
		return await _formatter.input_as_richtext_async(InputMapToGuideInput.convert(action))
	
	return ", ".join(
		[negative_x, positive_x, negative_y, positive_y]\
		.filter(func(a: StringName) -> bool: return a != null and not a.is_empty())\
		.map(func(a: StringName) -> String: return await _formatter.input_as_richtext_async(InputMapToGuideInput.convert(a)))
	)


func _validate_property(property: Dictionary) -> void:
	if property.name == "action":
		property.usage = PROPERTY_USAGE_DEFAULT if type == Type.Default else PROPERTY_USAGE_NO_EDITOR
	elif property.name in ["negative_x", "positive_x", "negative_y", "positive_y"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR if type == Type.Default else PROPERTY_USAGE_DEFAULT
