## Used by PromptIconFormatter
class_name InputMapToGuideInput


static func convert(action: StringName) -> GUIDEInput:
	var guide_input: GUIDEInput
	var input_events = InputMap.action_get_events(action)
	var input_event_index = min(Input.get_connected_joypads().size(), input_events.size())
	var event = input_events[input_event_index]
	
	if event is InputEventJoypadButton:
		guide_input = GUIDEInputJoyButton.new()
		guide_input.button = event.button_index
	if event is InputEventJoypadMotion:
		guide_input = GUIDEInputJoyAxis1D.new()
		guide_input.axis = event.axis
	if event is InputEventMouseButton:
		guide_input = GUIDEInputMouseButton.new()
		guide_input.button = event.button_index
	if event is InputEventKey:
		guide_input = GUIDEInputKey.new()
		var keycode : Key = event.get_physical_keycode()
		if keycode:
			keycode = event.get_physical_keycode_with_modifiers()
		else:
			keycode = event.get_keycode_with_modifiers()
		guide_input.key = DisplayServer.keyboard_get_keycode_from_physical(keycode)
	
	return guide_input
