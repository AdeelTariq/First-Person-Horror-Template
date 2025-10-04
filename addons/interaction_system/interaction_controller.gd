class_name InteractionController
extends Node

signal clear_action_prompts()
signal display_action_prompts(object_name: String, actions: Array[Interaction], center: bool)

static var current: InteractionController

var _focused_interactions: Array[Interaction] = []
var _focused_object_name: String = ""
var _picked_object: Node = null
var _is_focused_object_picked: bool = false


func _init() -> void:
	current = self


func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	for interaction in _focused_interactions:
		interaction.process_interaction(self)


func on_new_object_available(node: Node) -> void:
	if _picked_object != null:
		_prepare_prompts_for_display(InteractionContainer.from(_picked_object), true)
		return
	
	# Display action prompts
	if not InteractionContainer.is_attached(node):
		_clear_prompts()
		return
	var container: InteractionContainer = InteractionContainer.from(node)
	_prepare_prompts_for_display(container)


func _clear_prompts() -> void:
	if _focused_interactions.is_empty(): return
	clear_action_prompts.emit()
	_focused_interactions = []
	_focused_object_name = ""


func _prepare_prompts_for_display(interaction_container: InteractionContainer, picked_object: bool = false) -> void:
	var object_name: String = interaction_container.get_display_name()
	var interactions: Array[Interaction] = interaction_container.get_interactions()
	
	if _focused_interactions == interactions \
		and _focused_object_name == object_name \
		and _is_focused_object_picked == picked_object:
		return
	_focused_interactions = interactions
	_focused_object_name = object_name
	_is_focused_object_picked = picked_object
	display_action_prompts.emit(_focused_object_name, _focused_interactions, _is_focused_object_picked)


func refresh_prompts(interaction_container: InteractionContainer, picked_object: bool = false) -> void:
	_prepare_prompts_for_display(interaction_container, picked_object)


func grab_object(object: Node) -> void:
	_picked_object = object
	on_new_object_available(object)


func release_grabbed() -> void:
	_picked_object = null
	_clear_prompts()
