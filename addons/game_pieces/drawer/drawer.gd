@tool
class_name Drawer extends Node3D

@export_range(1., 10., 0.1) var speed: float = 3.
@export var release_distance: float = 4.

@onready var drawer_body: RigidBody3D = $RigidBody3D
@onready var slider_joint_3d: SliderJoint3D = $SliderJoint3D


var _interaction_controller: InteractionController = null
var _is_drawer_grabbed: bool:
	get(): return _interaction_controller != null
var _ray_point: Vector3 = Vector3.INF
var _mouse_point: Vector3 = Vector3.INF
var _initial_distance: float = 0.0


func _ready() -> void:
	slider_joint_3d.node_a = get_parent().get_path()


func _physics_process(_delta: float) -> void:
	if _is_drawer_grabbed:
		var ray_cast: RayCast3D = _interaction_controller.get_parent()
		var distance_to_player: float = ray_cast.global_position.distance_to(drawer_body.global_position)
		
		if distance_to_player > max(_initial_distance, release_distance):
			_drawer_released(_interaction_controller)
			return
		var point: Vector3 = ray_cast.to_global(ray_cast.target_position)
		var direction: Vector3 = point - _ray_point
		drawer_body.apply_force(direction * 100 * speed)
		_ray_point = point


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _is_drawer_grabbed:
		var mouse_event: InputEventMouseMotion = event
		var world_position: Vector3 = get_viewport().get_camera_3d().project_position(mouse_event.relative, .1)
		var direction: Vector3 = world_position - _mouse_point
		drawer_body.apply_force(direction * 1000 * speed)


func _while_drawer_grabbed(controller: InteractionController) -> void:
	_interaction_controller = controller
	if _ray_point != Vector3.INF: return
	_interaction_controller.grab_object(drawer_body)
	var ray_cast: RayCast3D = _interaction_controller.get_parent()
	_ray_point = ray_cast.to_global(ray_cast.target_position)
	_mouse_point = get_viewport().get_camera_3d().project_position(Vector2.ZERO, .1)
	GamePiecesEventBus.request_camera_lock(true)
	_initial_distance = ray_cast.global_position.distance_to(drawer_body.global_position)


func _drawer_released(_c: InteractionController) -> void:
	if _interaction_controller == null: return
	_interaction_controller.release_grabbed()
	_interaction_controller = null
	_ray_point = Vector3.INF
	_mouse_point = Vector3.INF
	GamePiecesEventBus.request_camera_lock(false)



func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not StaticBody3D:
		warnings.append("Drawer must be a child of a StaticBody3D")
	return warnings
