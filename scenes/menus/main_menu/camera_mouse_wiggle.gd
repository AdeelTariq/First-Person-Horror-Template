extends Camera3D

@export var max_rotation: Vector2 = Vector2(2.0, 2.0)
@export var smooth_speed: float = 5.0
@export var base_rotation: Vector3 = Vector3.ZERO

var target_offset: Vector2 = Vector2.ZERO
var current_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	base_rotation = rotation

func _process(delta: float) -> void:
	var viewport: Viewport = get_viewport()
	var viewport_size: Vector2 = viewport.size
	var mouse_pos: Vector2 = viewport.get_mouse_position()

	var normalized: Vector2 = (mouse_pos / viewport_size) * 2.0 - Vector2.ONE

	target_offset.x = -normalized.y * deg_to_rad(max_rotation.x)
	target_offset.y = -normalized.x * deg_to_rad(max_rotation.y)

	current_offset.x = lerp(current_offset.x, target_offset.x, delta * smooth_speed)
	current_offset.y = lerp(current_offset.y, target_offset.y, delta * smooth_speed)

	# Rebuild rotation each frame
	rotation = base_rotation + Vector3(current_offset.x, current_offset.y, 0.0)
