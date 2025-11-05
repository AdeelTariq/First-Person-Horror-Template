@icon("interaction.svg")
@tool
class_name Interaction
extends Node

@export var hide_while_grabbed: bool = false

@export var override_display_name: bool = false:
	set(value):
		override_display_name = value
		notify_property_list_changed()

@export var display_name: String = ""

signal on_trigger(controller: InteractionController)
signal on_complete(controller: InteractionController)

var control: GameControl:
	get(): return get_child(0)

var _triggered_last_frame: bool = false


func process_interaction(controller: InteractionController) -> bool:
	if Engine.is_editor_hint(): return false
	if control.is_triggered():
		perform(controller)
		_triggered_last_frame = true
		return true
	if _triggered_last_frame and not control.is_triggered():
		_triggered_last_frame = false
		complete(controller)
		return true
	_triggered_last_frame = false
	return false


func perform(controller: InteractionController) -> void:
	on_trigger.emit(controller)


func complete(controller: InteractionController) -> void:
	on_complete.emit(controller)


func get_display_name() -> String:
	return display_name if override_display_name else name


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not InteractionContainer and get_parent() is not InteractionContext:
		warnings.append("An Interaction must be a child of an InteractionContainer or InteractionContext")
	if get_child_count() != 1 or get_child(0) is not GameControl:
		warnings.append("A Interaction have exactly one GameControl child.")
	return warnings


func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint(): return
	if property.name == &"display_name":
		property.usage = PROPERTY_USAGE_DEFAULT if override_display_name else PROPERTY_USAGE_NO_EDITOR
