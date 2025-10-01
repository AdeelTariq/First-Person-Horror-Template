extends Node3D

@onready var wall_doorway_door: MeshInstance3D = $wall_doorway/wall_doorway_door
@onready var collider: CollisionShape3D = $wall_doorway/wall_doorway_door/StaticBody3D/CollisionShape3D

var swing_angle : float = 90.0
var starting_rot : float
var target_rot : float
var open_time : float = 2.0
var min_swing_time : float = 0.15

var swing_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_rot = wall_doorway_door.rotation.y


func interact(controller: InteractionController) -> void:
	var node3D: Node3D = controller.get_parent()
	var interact_pos: Vector3 = node3D.global_position
	if target_rot == starting_rot:
		return open(interact_pos)
	else:
		return close()


func open(interact_pos: Vector3 = Vector3.BACK) -> void:
	var swing_dir: float = sign(self.global_transform.origin.direction_to(interact_pos).dot(Vector3.BACK.rotated(Vector3.UP, wall_doorway_door.global_rotation.y)))
	target_rot = starting_rot + (deg_to_rad(swing_angle) * swing_dir)
	
	_swing()


func close() -> void:
	target_rot = starting_rot
	
	_swing()


func _swing() -> void:
	if swing_tween:
		swing_tween.kill()
	swing_tween = create_tween()
	swing_tween.finished.connect(_on_tween_finished)
	
	var calc_open_time: float = ((abs(target_rot - wall_doorway_door.rotation.y)) / deg_to_rad(swing_angle)) * open_time
	var duration: float = max(calc_open_time, min_swing_time)
	swing_tween.tween_property(wall_doorway_door, "rotation:y", target_rot, duration)\
	.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	if collider:
		collider.disabled = true


func _on_tween_finished() -> void:
	if collider:
		collider.disabled = false
	swing_tween.kill()
