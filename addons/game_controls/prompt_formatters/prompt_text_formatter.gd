## Formates the prompt as plain text.
## Doesn't depend on GUIDE and hence doesn't support GuideGameControl
class_name PromptTextFormatter extends PromptFormatter

func format_async(game_control: GameControl) -> String:
	if game_control is InputMapGameControl:
		if game_control.type == InputMapGameControl.Type.Default:
			return to_text(game_control.action)
	
		return ", ".join(
			[game_control.negative_x, game_control.positive_x, game_control.negative_y, game_control.positive_y]\
			.filter(func(a: StringName) -> bool: return a != null and not a.is_empty())\
			.map(func(a: StringName) -> String: return to_text(game_control.action))
		)
	if game_control is MouseGameControl:
		return "Mouse"
	return ""


static func to_text(action: StringName) -> String:
	var input_events = InputMap.action_get_events(action)
	var input_event_index = min(Input.get_connected_joypads().size(), input_events.size())
	var event = input_events[input_event_index]
	
	return event.as_text()
