@tool
extends InteractionController

## Require parent to be an RayCast3D and collision layers to be setup properly
class_name Area3DInteractionController

const DISABLE_COLLISION_GROUP = "disable_collision_while_grabbed"

## Join to exclude grabbed object from colliding with the player
@export var collision_excluding_joint: Joint3D
@export var right_hand: Node3D
@export var left_hand: Node3D
@export var pocket: Node3D

var area3d: Area3D
var _collider: Node3D = null
var _dropped_object_this_frame: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	area3d = get_parent()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	var active_controls: Array[String] = []
	for interaction in _focused_interactions:
		if interaction != null && interaction.process_interaction(self):
			active_controls.append(interaction.control.control_id())
	
	for equipped_object in _equipped_objects:
		if not is_instance_valid(equipped_object): 
			_equipped_objects.erase(equipped_object)
			continue
		var container: InteractionContainer = InteractionContainer.from(equipped_object)
		for interaction in container.get_interactions():
			if not interaction.control or active_controls.has(interaction.control.control_id()): continue
			if interaction.control.control_id() == "primary_action" and equipped_object.get_parent() != left_hand and left_hand.get_child_count() != 0: continue
			if interaction.control.control_id() == "secondary_action" and equipped_object.get_parent() != right_hand: continue
			interaction.process_interaction(self)


func get_collider() -> Node3D:
	if area3d.has_overlapping_areas():
		return area3d.get_overlapping_areas()[-1]
	return null

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _collider != get_collider():
		_collider = get_collider()
		collider_changed()
	if _collider == null and not _focused_interactions.is_empty() and _picked_object == null:
		_clear_prompts()
	# guarantees attempting a refresh each frame while an object is grabbed
	# refresh however will only succeed on the frame grabbed object is released.
	if _picked_object != null: 
		_collider = null


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not Area3D:
		warnings.append("An Area3DInteractionController must be a child of an Area3D")
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


func equip_in_hand(object: Node, left: bool) -> bool:
	var hand: Node3D = left_hand if left else right_hand
	for equipped: Node3D in hand.get_children():
		super.unequip_object(equipped)
		equipped.queue_free()
	super.equip_object(object)
	object.reparent(hand)
	object.position = Vector3.ZERO
	object.rotation = Vector3.ZERO
	return true


func unequip_object(object: Node) -> bool:
	super.unequip_object(object)
	return true


func drop_object(object: Node) -> bool:
	return false # no dropping objects


func _delayed_reset_flag() -> void:
	await get_tree().create_timer(0.1).timeout
	_dropped_object_this_frame = false


func refresh_prompts(interaction_container: InteractionContainer, picked_object: bool = false) -> void:
	if InteractionContainer.from(_collider) != interaction_container: return
	_prepare_prompts_for_display(interaction_container, picked_object)
