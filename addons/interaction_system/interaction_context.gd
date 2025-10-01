@icon("interaction_context.svg")
@tool
class_name InteractionContext extends Node

@export_range(0, 100, 1, "or_greater")
var context_id: int = 0

@export var override_display_name: bool:
	set(value):
		override_display_name = value
		notify_property_list_changed()

var display_name: String = ""


func enable_context() -> void:
	var container: InteractionContainer = get_parent()
	container.enable(context_id)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not InteractionContainer:
		warnings.append("An InteractionContext must be a child of an InteractionContainer")
	
	if get_child_count() == 0:
		warnings.append("Add at least one Interaction child")
	else:
		var children: Array[Node] = get_children()
		for child: Node in children:
			if not child is Interaction:
				warnings.append("child must be an Interaction")
	return warnings

func _get_property_list() -> Array[Dictionary]:
	if Engine.is_editor_hint():
		var ret: Array[Dictionary] =[]
		if override_display_name:
			ret.append({
			"name": &"display_name",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			})
		return ret
	return []
