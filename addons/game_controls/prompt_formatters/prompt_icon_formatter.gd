## Formates the prompt as icon.
## Depends on GUIDE addon.
class_name PromptIconFormatter extends PromptFormatter

var _formatter: GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts()
var _mouse_guide_input: GUIDEInput = GUIDEInputMouseAxis2D.new()

func format_async(game_control: GameControl) -> String:
	if game_control is GuideGameControl:
		return await _formatter.action_as_richtext_async(game_control.action)
	if game_control is InputMapGameControl:
		if game_control.type == InputMapGameControl.Type.Default:
			return await _formatter.input_as_richtext_async(InputMapToGuideInput.convert(game_control.action))
	
		return ", ".join(
			[game_control.negative_x, game_control.positive_x, game_control.negative_y, game_control.positive_y]\
			.filter(func(a: StringName) -> bool: return a != null and not a.is_empty())\
			.map(func(a: StringName) -> String: return await _formatter.input_as_richtext_async(InputMapToGuideInput.convert(a)))
		)
	if game_control is MouseGameControl:
		return await _formatter.input_as_richtext_async(_mouse_guide_input)
	return ""
