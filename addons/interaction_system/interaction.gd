@icon("interaction.svg")
@tool
class_name Interaction
extends Node

@export var is_hold: bool = false

signal on_trigger(controller: InteractionController)
signal on_complete(controller: InteractionController)

var control: GameControl:
	get(): return get_child(0)

var _triggered_last_frame: bool = false


func process_interaction(controller: InteractionController) -> void:
	if Engine.is_editor_hint(): return
	if control.is_triggered():
		perform(controller)
	if _triggered_last_frame and not control.is_triggered():
		complete(controller)
	
	_triggered_last_frame = control.is_triggered()


func perform(controller: InteractionController) -> void:
	on_trigger.emit(controller)


func complete(controller: InteractionController) -> void:
	on_complete.emit(controller)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not InteractionContainer and get_parent() is not InteractionContext:
		warnings.append("An Interaction must be a child of an InteractionContainer or InteractionContext")
	if get_child_count() != 1 or get_child(0) is not GameControl:
		warnings.append("A Interaction have exactly one GameControl child.")
	return warnings
