extends RigidBody3D

@export var pull_force: float = 10

var _interaction_controller: InteractionController = null
var _is_grabbed: bool:
	get(): return _interaction_controller != null
var initial_basis: Basis


func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	if not _is_grabbed: return
	
	# Calculate linear velocity
	var hand_position: Vector3 = Player.current.hand.global_position
	var move_distance: float = global_position.distance_to(hand_position)
	var velocity: Vector3 = global_position.direction_to(hand_position) * (pull_force / mass) * move_distance
	linear_velocity = velocity
	
	# Calculate angular velocity
	var reference_node: Node3D = _interaction_controller.get_parent()
	var target_basis: Basis = reference_node.global_transform.basis * initial_basis #Basis.looking_at(target_rotation, reference_node.global_basis.y)
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
		angular_velocity = axis * angle / 0.01
	else:
		angular_velocity = Vector3.ZERO


func _while_drawer_grabbed(controller: InteractionController) -> void:
	if _interaction_controller != null: return
	apply_central_force(Vector3.ONE)
	_interaction_controller = controller
	_interaction_controller.grab_object(self)
	
	var reference_node: Node3D = _interaction_controller.get_parent()
	initial_basis = reference_node.global_transform.basis.inverse() * global_transform.basis


func _drawer_released(_c: InteractionController) -> void:
	if _interaction_controller == null: return
	_interaction_controller.release_grabbed()
	_interaction_controller = null
