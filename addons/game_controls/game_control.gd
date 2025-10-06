@abstract
class_name GameControl extends Node

@abstract func value() -> float
@abstract func value_axis_2d() -> Vector2
@abstract func value_axis_3d() -> Vector3

func is_triggered() -> bool:
	return value() != 0
