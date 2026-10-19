class_name CompositorFxBinding
extends Resource

## Name AnimationPlayer tracks (must be unique on the WorldEnvironment).
@export var anim_property: String = ""
@export var effect_index: int = 0
## Property on the CompositorEffect (e.g. intensity, blur_strength).
@export var effect_property: String = "intensity"
@export var value: float = 0.0:
	set(v):
		if is_equal_approx(value, v):
			return
		value = v
		emit_changed()
