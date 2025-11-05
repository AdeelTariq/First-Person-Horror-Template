class_name MouseGameControl extends GameControl

# The mouse movement since the last frame. 
var _mouse_movement: Vector2 = Vector2.ZERO

func control_id() -> String:
	return "mouse_movement"


func value() -> float:
	return 0.0


func value_axis_2d() -> Vector2:
	var window = Engine.get_main_loop().get_root()
	var input: Vector2 = _mouse_movement
	# We want real pixels, so we need to factor in any scaling that the window does.
	var window_size:Vector2 = window.get_screen_transform().affine_inverse() * Vector2(window.size)
	return -Vector2(input.x / window_size.x, input.y / window_size.y)


func value_axis_3d() -> Vector3:
	var value_2d: Vector2 = value_axis_2d()
	return Vector3(value_2d.x, value_2d.y, 0.0)


func _ready() -> void:
	get_tree().process_frame.connect(
		func(): _mouse_movement = Vector2.ZERO
	)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Emit the mouse moved signal with the distance moved
		_mouse_movement += event.relative
