@tool
class_name CompositorFxAnim
extends WorldEnvironment

## Drive WorldEnvironment compositor post FX from AnimationPlayer.
## AnimationPlayer cannot resolve compositor effect paths or array-nested values, so
## each binding exposes a flat float (`anim_property`) that you key in animations.

@export var bindings: Array[CompositorFxBinding] = []:
	set(v):
		_disconnect_bindings()
		bindings = v
		_connect_bindings()
		notify_property_list_changed()
		_apply_all()


func _ready() -> void:
	_connect_bindings()
	_apply_all()


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	for binding in bindings:
		if binding == null or binding.anim_property.is_empty():
			continue
		props.append({
			"name": binding.anim_property,
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"hint": PROPERTY_HINT_NONE,
		})
	return props


func _get(property: StringName) -> Variant:
	var binding := _find_binding(property)
	if binding != null:
		return binding.value
	return null


func _set(property: StringName, value: Variant) -> bool:
	var binding := _find_binding(property)
	if binding == null:
		return false
	binding.value = float(value)
	_apply_binding(binding)
	return true


func _connect_bindings() -> void:
	for binding in bindings:
		if binding != null and not binding.changed.is_connected(_on_binding_changed):
			binding.changed.connect(_on_binding_changed)


func _disconnect_bindings() -> void:
	for binding in bindings:
		if binding != null and binding.changed.is_connected(_on_binding_changed):
			binding.changed.disconnect(_on_binding_changed)


func _on_binding_changed() -> void:
	notify_property_list_changed()
	_apply_all()


func _apply_all() -> void:
	for binding in bindings:
		_apply_binding(binding)


func _apply_binding(binding: CompositorFxBinding) -> void:
	if binding == null or binding.effect_property.is_empty():
		return
	var fx := _effect_at(binding.effect_index)
	if fx != null:
		fx.set(binding.effect_property, binding.value)


func _find_binding(property: StringName) -> CompositorFxBinding:
	var key := String(property)
	for binding in bindings:
		if binding != null and binding.anim_property == key:
			return binding
	return null


func _effect_at(index: int) -> CompositorEffect:
	if compositor == null:
		return null
	var effects: Array = compositor.compositor_effects
	if index < 0 or index >= effects.size():
		return null
	return effects[index] as CompositorEffect
