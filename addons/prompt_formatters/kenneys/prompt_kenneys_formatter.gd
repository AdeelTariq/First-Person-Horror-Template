## Formates the prompt as kenney icon.
## Requires a download of kenneys icons via the option at: 
## Project > Tools > Add Input Prompt Icons
class_name PromptKenneysFormatter extends PromptFormatter

var _size: int
func _init(size: int = 32) -> void:
	_size = size


func format_async(game_control: GameControl) -> String:
	if game_control is InputMapGameControl:
		if game_control.type == InputMapGameControl.Type.Default:
			var icon: Texture = get_action_icon(game_control.action)
			return "[img width=%d]%s[/img]" % [_size, icon.resource_path]
	
		return ", ".join(
			[game_control.negative_x, game_control.positive_x, game_control.negative_y, game_control.positive_y]\
			.filter(func(a: StringName) -> bool: return a != null and not a.is_empty())\
			.map(func(a: StringName) -> String: 
			var icon: Texture = get_action_icon(a)
			return "[img width=%d]%s[/img]" % [_size, icon.resource_path]
			)
		)
	if game_control is MouseGameControl:
		var icon: Texture = InputIconMapperGlobal.matching_icons["Mouse Move"]
		return "[img width=%d]%s[/img]" % [_size, icon.resource_path]
	return ""


func get_action_icon(input_action : String) -> Texture:
	var input_events = InputMap.action_get_events(input_action)
	var input_event_index = min(Input.get_connected_joypads().size(), input_events.size() - 1)
	var icon = InputIconMapperGlobal.get_icon(input_events[input_event_index]) as Texture
	if not icon:
		icon = InputIconMapperGlobal.get_icon(input_events[0]) as Texture
	return icon
