@abstract
class_name GameControl extends Node

@abstract func control_id() -> String
@abstract func value() -> float
@abstract func value_axis_2d() -> Vector2
@abstract func value_axis_3d() -> Vector3

var _triggered: bool = false

func is_triggered() -> bool:
	return value() != 0

## Checks if this is the first trigger event
## Only returns true for the first trigger event til release;
## Similar to is_just_pressed. But only call this once per frame.
func is_first_triggered() -> bool:
	if not is_triggered(): 
		_triggered = false
		return false
	if _triggered: return false
	_triggered = true
	return true
