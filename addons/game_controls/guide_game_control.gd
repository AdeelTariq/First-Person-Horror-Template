class_name GuideGameControl extends GameControl

@export var action: GUIDEAction

@onready var _formatter: GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts()

func value() -> float:
	return action.value_axis_1d

func value_axis_2d() -> Vector2:
	return action.value_axis_2d

func value_axis_3d() -> Vector3:
	return action.value_axis_3d

func is_triggered() -> bool:
	return action.is_triggered()

func display_text_async() -> String:
	return await _formatter.action_as_richtext_async(action)
