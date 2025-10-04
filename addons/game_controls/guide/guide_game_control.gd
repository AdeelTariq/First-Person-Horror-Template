class_name GuideGameControl extends GameControl

@export var action: GUIDEAction

func value() -> float:
	return action.value_axis_1d

func value_axis_2d() -> Vector2:
	return action.value_axis_2d

func value_axis_3d() -> Vector3:
	return action.value_axis_3d

func is_triggered() -> bool:
	return action.is_triggered()
