@tool
extends InteractionController

## Require parent to be an RayCast3D and collision layers to be setup properly
class_name RayCast3DInteractionController

var raycast: RayCast3D
var _collider: Node3D = null

func _ready() -> void:
	if Engine.is_editor_hint(): return
	raycast = get_parent()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _collider != raycast.get_collider():
		_collider = raycast.get_collider()
		collider_changed()
	if _collider == null and not _focused_interactions.is_empty():
		_clear_prompts()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not RayCast3D:
		warnings.append("An Area2DInteractionController must be a child of an RayCast3D")
	return warnings


func collider_changed() -> void:
	if _is_interactable_available():
		on_new_object_available(_collider)
	else:
		_clear_prompts()


## Check if any node is within range
func _is_interactable_available() -> bool:
	return _collider != null and InteractionContainer.is_attached(_collider)
