@tool
class_name InputMapGameControl extends GameControl

enum Type {Default, MultiDimensional}

@export var type: Type = Type.Default:
	set(value):
		type = value
		notify_property_list_changed()

## When GameControl node name is different than the action name
@export var override_action_name: bool = false:
	set(value):
		override_action_name = value
		notify_property_list_changed()

@export var _action: StringName = ""

var action: StringName:
	get():
		return _action if override_action_name else name

@export var negative_x: StringName
@export var positive_x: StringName
@export var negative_y: StringName
@export var positive_y: StringName

func control_id() -> String:
	return action


func value() -> float:
	if type == Type.Default:
		return Input.get_action_strength(action)
	else:
		var use_workaround: bool = (InputMap.action_get_events(negative_x) + InputMap.action_get_events(positive_x))\
			.any(func(e: InputEvent) -> bool: return e is InputEventMouseButton)
		if use_workaround:
			return (1 if Input.is_action_just_pressed(positive_x) else 0) - (1 if Input.is_action_just_pressed(negative_x) else 0)
		return Input.get_axis(negative_x, positive_x)

func value_axis_2d() -> Vector2:
	return Input.get_vector(negative_x, positive_x, negative_y, positive_y)

func value_axis_3d() -> Vector3:
	var dir: Vector2 = Input.get_vector(negative_x, positive_x, negative_y, positive_y)
	return Vector3(dir.x, 0.0, dir.y)

func _validate_property(property: Dictionary) -> void:
	if property.name == "action":
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "_action":
		property.usage = PROPERTY_USAGE_DEFAULT if type == Type.Default and override_action_name else PROPERTY_USAGE_NO_EDITOR
	elif property.name in ["negative_x", "positive_x", "negative_y", "positive_y"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR if type == Type.Default else PROPERTY_USAGE_DEFAULT
