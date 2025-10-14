@tool
extends InteractionController

## Require parent to be an RayCast3D and collision layers to be setup properly
class_name RayCast3DInteractionController

const DISABLE_COLLISION_GROUP = "disable_collision_while_grabbed"

## Join to exclude grabbed object from colliding with the player
@export var collision_excluding_joint: Joint3D

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
	if _collider == null and not _focused_interactions.is_empty() and _picked_object == null:
		_clear_prompts()
	# guarantees attempting a refresh each frame while an object is grabbed
	# refresh however will only succeed on the frame grabbed object is released.
	if _picked_object != null: 
		_collider = null


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not RayCast3D:
		warnings.append("An Area2DInteractionController must be a child of an RayCast3D")
	return warnings


func collider_changed() -> void:
	if _is_interactable_available():
		on_new_object_available(_collider)
	elif _picked_object == null:
		_clear_prompts()


## Check if any node is within range
func _is_interactable_available() -> bool:
	return _collider != null and InteractionContainer.is_attached(_collider)


func grab_object(object: Node) -> void:
	super.grab_object(object)
	if not object.is_in_group(DISABLE_COLLISION_GROUP): return
	if collision_excluding_joint == null: return
	collision_excluding_joint.node_b = object.get_path()


func release_grabbed() -> void:
	super.release_grabbed()
	if collision_excluding_joint == null: return
	collision_excluding_joint.node_b = ""
