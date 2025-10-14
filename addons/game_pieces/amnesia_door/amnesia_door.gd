@tool
class_name AmnesiaDrawer extends Node3D

@export_range(1., 10., 0.1) var speed: float = 3.
@export var release_distance: float = 4.

@export var upper_angle: float:
	set(value): 
		upper_angle = value
		if hinge_joint_3d == null: return
		hinge_joint_3d.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, deg_to_rad(value))

@export var lower_angle: float:
	set(value):
		lower_angle = value
		if hinge_joint_3d == null: return
		hinge_joint_3d.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, deg_to_rad(value))


@onready var door_body: RigidBody3D = $RigidBody3D
@onready var collider: CollisionShape3D = $RigidBody3D/CollisionShape3D
@onready var hinge_joint_3d: HingeJoint3D = $HingeJoint3D


var _interaction_controller: InteractionController = null
var _is_grabbed: bool:
	get(): return _interaction_controller != null
var _ray_point: Vector3 = Vector3.INF


func _ready() -> void:
	hinge_joint_3d.node_a = get_parent().get_path()
	hinge_joint_3d.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, deg_to_rad(upper_angle))
	hinge_joint_3d.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, deg_to_rad(lower_angle))


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _is_grabbed:
		var ray_cast: RayCast3D = _interaction_controller.get_parent()
		var distance_to_player: float = ray_cast.global_position.distance_to(door_body.global_position)
		if distance_to_player > release_distance:
			_door_released(_interaction_controller)
			return
		var point: Vector3 = ray_cast.to_global(ray_cast.target_position)
		var move_dir: Vector3 = point - _ray_point
		move_dir.y = 0
		var direction: Vector3 = ray_cast.global_position.direction_to(global_position)
		var amount: float = move_dir.dot(direction)
		if abs(amount) <= 0: return
		var swing_dir: float = sign(direction.dot(-global_basis.z))
		door_body.apply_torque(Vector3(0, amount * swing_dir, 0) * 100 * speed)
		_ray_point = point


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _is_grabbed:
		var mouse_event: InputEventMouseMotion = event
		var ray_cast: RayCast3D = _interaction_controller.get_parent()
		var move_dir: Vector3 = Vector3(mouse_event.relative.x, 0, mouse_event.relative.y) / 10.
		var direction: Vector3 = ray_cast.global_position.direction_to(global_position)
		var amount: float = move_dir.dot(Vector3.FORWARD)
		var swing_dir: float = sign(direction.dot(-global_basis.z))
		door_body.apply_torque(Vector3(0, amount * swing_dir, 0) * speed)


func _while_door_grabbed(controller: InteractionController) -> void:
	_interaction_controller = controller
	if _ray_point != Vector3.INF: return
	_interaction_controller.grab_object(door_body)
	var ray_cast: RayCast3D = _interaction_controller.get_parent()
	_ray_point = ray_cast.to_global(ray_cast.target_position)
	GamePiecesEventBus.request_camera_lock(true)


func _door_released(_c: InteractionController) -> void:
	if _interaction_controller == null: return
	_interaction_controller.release_grabbed()
	_interaction_controller = null
	_ray_point = Vector3.INF
	GamePiecesEventBus.request_camera_lock(false)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not StaticBody3D:
		warnings.append("Drawer must be a child of a StaticBody3D")
	return warnings
