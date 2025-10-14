extends RigidBody3D

@export var pull_force: float = 15
@export var throw_power: float = 10
@export var interaction_context_when_grabbed: int = 1
@export var change_distance_interaction: Interaction

var _interaction_controller: InteractionController = null
var _is_grabbed: bool:
	get(): return _interaction_controller != null
var _initial_basis: Basis
var _position_offset: float = 1.0
var _initial_position: Vector3 = Vector3.ZERO
var _min_offset: float = 0.65
var _max_offset: float = 1.65
var _is_rotating: bool = false


func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	if not _is_grabbed: return
	
	var reference_node: Node3D = _interaction_controller.get_parent()
	
	# Calculate linear velocity
	var hand_position: Vector3 = reference_node.to_global(_initial_position * _position_offset)
	var move_distance: float = global_position.distance_to(hand_position)
	var velocity: Vector3 = global_position.direction_to(hand_position) * (pull_force / mass) * move_distance
	linear_velocity = velocity
	
	# Calculate angular velocity
	var target_basis: Basis = reference_node.global_transform.basis * _initial_basis #Basis.looking_at(target_rotation, reference_node.global_basis.y)
	# Get rotational difference as quaternion
	var quaternion_current: Quaternion = global_transform.basis.get_rotation_quaternion()
	var quaternion_target: Quaternion = target_basis.get_rotation_quaternion()
	var quaternion_diff: Quaternion = quaternion_target * quaternion_current.inverse()
	if quaternion_diff.dot(Quaternion.IDENTITY) < 0:
		quaternion_diff = -quaternion_diff  # ensure shortest path
	
	# Convert to axis-angle
	var angle: float = quaternion_diff.get_angle()
	if angle > 0.001 and angle < PI:
		var axis: Vector3 = quaternion_diff.get_axis()
		angular_velocity = axis * (angle  * (pull_force / (mass * 100))) / 0.01
	else:
		angular_velocity = Vector3.ZERO


func _input(event: InputEvent) -> void:
	if not _is_rotating or event is not InputEventMouseMotion: return
	var mouse_event: InputEventMouseMotion = event
	var offset: Basis = Basis()
	offset = offset.rotated(Vector3.RIGHT, deg_to_rad(mouse_event.relative.y))
	offset = offset.rotated(Vector3.UP, deg_to_rad(mouse_event.relative.x))
	
	_initial_basis = offset * _initial_basis


func _while_grabbed(controller: InteractionController) -> void:
	if _interaction_controller != null: return
	_interaction_controller = controller
	_interaction_controller.grab_object(self)
	apply_central_force(Vector3.ONE)
	_position_offset = 1.0
	var reference_node: Node3D = _interaction_controller.get_parent()
	_initial_basis = reference_node.global_transform.basis.inverse() * global_transform.basis
	_initial_position = reference_node.to_local(global_position)
	# Bring it closer to reference node
	_initial_position *= 0.9
	InteractionContainer.from(self).enable(interaction_context_when_grabbed)


func _released(_c: InteractionController) -> void:
	if _c != _interaction_controller: return
	if _interaction_controller == null: return
	_interaction_controller.release_grabbed()
	_interaction_controller = null
	InteractionContainer.from(self).enable()
	GamePiecesEventBus.request_camera_lock(false)


func _on_change_distance(controller: InteractionController) -> void:
	if controller != _interaction_controller: return
	_position_offset += change_distance_interaction.control.value() * 0.1
	_position_offset = clampf(_position_offset, _min_offset, _max_offset)


func _while_rotating(controller: InteractionController) -> void:
	if controller != _interaction_controller: return
	_is_rotating = true
	GamePiecesEventBus.request_camera_lock(true)


func _stopped_rotating(controller: InteractionController) -> void:
	if controller != _interaction_controller: return
	_is_rotating = false
	GamePiecesEventBus.request_camera_lock(false)


func _on_throw(controller: InteractionController) -> void:
	if controller != _interaction_controller: return
	_released(controller)
	InteractionContainer.from(self).disable() # Disable interactions while throwing
	var reference_node: Node3D = controller.get_parent()
	var hand_position: Vector3 = reference_node.to_global(_initial_position * _position_offset)
	var direction: Vector3 = reference_node.global_position.direction_to(hand_position)
	apply_impulse(direction * throw_power)
	await get_tree().process_frame
	InteractionContainer.from(self).enable()
