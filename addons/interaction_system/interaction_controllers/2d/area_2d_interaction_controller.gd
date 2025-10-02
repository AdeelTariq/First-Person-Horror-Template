@tool
extends InteractionController

## Require parent to be an Area2D and collision layers to be setup properly
class_name Area2DInteractionController


func _ready() -> void:
	var area: Area2D = get_parent()
	area.area_entered.connect(
		func(_area: Area2D) -> void:
			if _is_interactable_available():
				on_new_object_available(_get_available_interactable())
	)
	area.area_exited.connect(
		func(_area: Area2D) -> void:
			if _is_interactable_available():
				on_new_object_available(_get_available_interactable())
			else:
				_clear_prompts()
	)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not Area2D:
		warnings.append("An Area2DInteractionController must be a child of an Area2D")
	return warnings


## Check if any node is within range
func _is_interactable_available() -> bool:
	var area: Area2D = get_parent()
	# not using has_overlapping_areas because that seems to be true even when list is empty
	return not area.get_overlapping_areas().filter(
		func(a: Area2D) -> bool: return InteractionContainer.is_attached(a)
	).is_empty()


func _get_available_interactable() -> Node:
	var area: Area2D = get_parent()
	return area.get_overlapping_areas().filter(
		func(a: Area2D) -> bool: return InteractionContainer.is_attached(a)
	)[0]
