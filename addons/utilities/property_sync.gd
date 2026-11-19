@tool
extends Node
class_name PropertySync
## One-way sync of a single property from [member source] to [member target].
## Both nodes must expose [member property].

@export var source: Node
@export var target: Node
@export var property: StringName
## When true, syncs during [method Node._physics_process] instead of [method Node._process].
@export var sync_in_physics: bool = false

var _valid: bool = false


func _ready() -> void:
	_valid = _validate()
	if not _valid:
		set_process(false)
		set_physics_process(false)
		return
	_apply()
	set_process(not sync_in_physics)
	set_physics_process(sync_in_physics)


func _process(_delta: float) -> void:
	_apply()


func _physics_process(_delta: float) -> void:
	_apply()


func _apply() -> void:
	if not _valid or source == null or target == null:
		return
	target.set(property, source.get(property))


func _validate() -> bool:
	if source == null or target == null:
		push_warning("%s: source and target must be assigned." % name)
		return false
	if property == &"":
		push_warning("%s: property must be set." % name)
		return false
	if not _has_property(source, property):
		push_warning(
			"%s: property '%s' not found on %s."
			% [name, property, source.get_class()]
		)
		return false
	return true


func _has_property(node: Node, prop: StringName) -> bool:
	for info: Dictionary in node.get_property_list():
		if info.name == prop:
			return true
	return false
