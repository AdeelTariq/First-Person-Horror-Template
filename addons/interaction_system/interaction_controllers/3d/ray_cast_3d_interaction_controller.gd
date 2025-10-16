@tool
extends InteractionController

## Require parent to be an RayCast3D and collision layers to be setup properly
class_name RayCast3DInteractionController

const DISABLE_COLLISION_GROUP = "disable_collision_while_grabbed"

## Join to exclude grabbed object from colliding with the player
@export var collision_excluding_joint: Joint3D
@export var hands: Array[Node3D]

var raycast: RayCast3D
var _collider: Node3D = null
var _dropped_object_this_frame: bool = false

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


func equip_object(object: Node) -> bool:
	var empty_hands: Array[Node3D] = hands.filter(
		func(h: Node3D) -> bool: 
			return h != null and h.get_child_count() == 0
	)
	if empty_hands.is_empty(): return false
	super.equip_object(object)
	object.reparent(empty_hands[0])
	object.position = Vector3.ZERO
	object.rotation = Vector3.ZERO
	return true


func drop_object(object: Node) -> bool:
	if _dropped_object_this_frame: return false
	
	var space_state: PhysicsDirectSpaceState3D = get_viewport().world_3d.direct_space_state
	var hand: Node3D = hands[hands.find_custom(func(h: Node3D) -> bool: return h.is_ancestor_of(object))]
	var from = hand.global_position
	var to = from + Vector3.DOWN * 1000
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	if not result: return false

	# placing node at collision point so its lowest point is touching it, not origin
	var collision_point: Vector3 = result.position
	object.reparent(get_tree().root)
	if object.has_method("get_aabb"):
		var aabb: AABB = object.get_aabb()
		object.global_transform.origin = collision_point + Vector3(0, aabb.size.y / 2, 0)
	else:
		object.global_transform.origin = collision_point
	object.rotation.x = 0
	object.rotation.z = 0
	
	super.drop_object(object)
	_dropped_object_this_frame = true
	_delayed_reset_flag()
	return true

func _delayed_reset_flag() -> void:
	await get_tree().create_timer(0.1).timeout
	_dropped_object_this_frame = false
