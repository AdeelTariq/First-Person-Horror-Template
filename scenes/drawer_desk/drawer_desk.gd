extends Node3D

@export_range(1., 10., 0.1) var speed: float = 3.
@export var release_distance: float = 3.

@onready var drawer_body: RigidBody3D = $RigidBody3D


var _interaction_controller: InteractionController = null
var _is_drawer_grabbed: bool:
	get(): return _interaction_controller != null
var _ray_point: Vector3 = Vector3.INF


func _physics_process(_delta: float) -> void:
	if _is_drawer_grabbed:
		var ray_cast: RayCast3D = _interaction_controller.get_parent()
		var distance_to_player: float = ray_cast.global_position.distance_to(drawer_body.global_position)
		if distance_to_player > release_distance:
			_drawer_released(_interaction_controller)
			return
		var point: Vector3 = ray_cast.to_global(ray_cast.target_position)
		var direction: Vector3 = point - _ray_point
		drawer_body.apply_force(direction * 100 * speed)
		_ray_point = point


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _is_drawer_grabbed:
		var mouse_event: InputEventMouseMotion = event
		var ray_cast: RayCast3D = _interaction_controller.get_parent()
		var mouse_move_dir: Vector3 = Vector3(mouse_event.relative.x, 0, mouse_event.relative.y)
		var direction: Vector3 = ray_cast.global_position.direction_to(global_position)
		var amount: float = mouse_move_dir.dot(Vector3.FORWARD)
		var move_dir: float = sign(direction.dot(Vector3.BACK))
		drawer_body.apply_force(Vector3(0, 0, amount * move_dir) * speed)


func _while_drawer_grabbed(controller: InteractionController) -> void:
	_interaction_controller = controller
	if _ray_point != Vector3.INF: return
	_interaction_controller.grab_object(drawer_body)
	var ray_cast: RayCast3D = _interaction_controller.get_parent()
	_ray_point = ray_cast.to_global(ray_cast.target_position)
	Player.current.lock_camera = true


func _drawer_released(_c: InteractionController) -> void:
	if _interaction_controller == null: return
	_interaction_controller.release_grabbed()
	_interaction_controller = null
	_ray_point = Vector3.INF
	Player.current.lock_camera = false
