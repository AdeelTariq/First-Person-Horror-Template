@icon("interaction_container.svg")
@tool
class_name InteractionContainer
extends Node

@export var default_context_id: int = 0
@export var display_name: String = ""

@export var override_disabled_display_name: bool:
	set(value):
		override_disabled_display_name = value
		notify_property_list_changed()

var disabled_display_name: String = ""


var _enabled_context_id: int = default_context_id:
	set(value):
		_enabled_context_id = value
		_refresh_interactions()

var _interactions: Array[Interaction] = []

func _ready() -> void:
	get_parent().set_meta("interaction_container", self)
	_refresh_interactions()


func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		_refresh_interactions()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_child_count() == 0:
		warnings.append("Add at least one Interaction or InteractionContext child")
	else:
		var children: Array[Node] = get_children()
		for child: Node in children:
			if child is not Interaction and child is not InteractionContext:
				warnings.append("child must be an Interaction or InteractionContext")
	return warnings


func _refresh_interactions() -> void:
	_interactions = []
	if _enabled_context_id < 0: return
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is InteractionContext:
			var context: InteractionContext = child
			if context.context_id == _enabled_context_id:
				_interactions.append_array(child.find_children("*", "Interaction", true, false))
		if child is Interaction:
			_interactions.append(child)


func get_interactions() -> Array[Interaction]: return _interactions


func disable() -> void:
	_enabled_context_id = -1


func enable(with_context: int = default_context_id) -> void:
	_enabled_context_id = with_context


func is_enabled() -> bool:
	return _enabled_context_id > -1


func get_display_name() -> String:
	if _enabled_context_id < 0 and override_disabled_display_name:
		return disabled_display_name
	if _enabled_context_id >= 0:
		var children: Array[Node] = get_children()
		for child: Node in children:
			if child is InteractionContext:
				var context: InteractionContext = child
				if context.context_id == _enabled_context_id and context.override_display_name:
					return context.display_name
	return display_name


func _get_property_list() -> Array[Dictionary]:
	if Engine.is_editor_hint():
		var ret: Array[Dictionary] = []
		if override_disabled_display_name:
			ret.append({
			"name": &"disabled_display_name",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			})
		return ret
	return []


static func is_attached(node: Node) -> bool:
	return node.has_meta("interaction_container") and node.get_meta("interaction_container") is InteractionContainer


static func detach(node: Node) -> void:
	return node.remove_meta("interaction_container")


static func from(node: Node) -> InteractionContainer:
	assert(node.get_meta("interaction_container") is InteractionContainer)
	return node.get_meta("interaction_container")
