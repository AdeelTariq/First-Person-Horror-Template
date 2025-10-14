@tool
## Stuff here?
class_name Player extends CharacterBody3D

@export var footsteps_sound: AudioStream

## The constant value that footsteps and head bob are calculated against
const BASE_WALK_SPEED: float = 3.0
const BOB_FREQ: float = BASE_WALK_SPEED
const LEAN_SPEED: float = 0.1

@export_category("User Settings")
## Look/Mouse sensitivity
@export var mouse_sensitivity: float = 4

## How much head bobs
@export var head_bob_strength: float = 0.025

## Base FOV Setting
@export var base_fov: float = 75.0
@export var toggle_crouch: bool = true

@export_category("Other Configuration")
@export_group("Movement")
@export var walk_speed = 3.0
@export var sprint_speed: float = 6.0
@export var crouch_speed = 1.5
@export var jump_power: float = 4
## How much fov changes from base value based on current velocity
@export var fov_change: float = 1
## To disable sprint for when player runs out of stamina for example
@export var disable_sprint: bool = false
@export_group("Crouching")
@export var full_height: float = 1.
@export var crouch_height: float = .5
## Time it takes to crouch or stand back up
@export var crouch_time: float = 0.16
@export_group("Leaning")
@export var camera_base_position: Vector3 = Vector3.ZERO
@export var camera_lean_position: Vector3 = Vector3(1., -0.1, 0.)
@export_group("Other")
@export var lock_camera: bool = false

@export_category("Info")
@export_custom(PROPERTY_HINT_MULTILINE_TEXT, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR)
var _1: String = "Player node requires uniquely named children inheriting from GameControl.
Required: %look, %move.
Optional: %jump, %sprint, %crouch, %lean, %zoom
"

## Control where x and z values will control the movement direction of the player
## The value_3d must have a value of (0, 0, -1) for moving forward
## and a value of (1, 0, 0) for moving/strafing right
## only x and z are used. y is discarded.
@onready var move_control: GameControl = %move
## Control where x and y values will control the look direction of the player
## x and y values must represent the delta mouse position as window-relative units between 0 and 1
## E.g. if a mouse cursor moves half a screen to the right and down, then 
## this modifier will return (0.5, 0.5).
@onready var look_control: GameControl = %look

@onready var head: Node3D = %Head
@onready var neck: Node3D = %Neck
@onready var camera: Camera3D = %Camera3D
@onready var footsteps: AudioStreamPlayer3D = %FootSteps
@onready var foot_steps_animation_player: AnimationPlayer = %FootStepsAnimationPlayer
@onready var camera_animation_player: AnimationPlayer = %CameraAnimationPlayer
@onready var generic_6dof_joint_3d: Joint3D = %Generic6DOFJoint3D
@onready var hand: Marker3D = %Hand
@onready var ceiling: ShapeCast3D = $Ceiling


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = 9.8
var speed: float
var on_floor_last_frame: bool = false
var bob_time: float = 0.0
var crouch_released_last_frame: bool = true
var crouching: bool:
	get():
		return abs(scale.y - crouch_height) < 0.01
var _crouch_tween: Tween


func _ready() -> void:
	if Engine.is_editor_hint(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	footsteps.stream = footsteps_sound


func _physics_process(delta) -> void:
	if Engine.is_editor_hint(): return
	handle_effects(delta)
	handle_falling(delta)
	handle_jump()
	handle_crouch(delta)
	set_movement_speed()
	look_around()
	handle_movement(delta)
	handle_head_bob(delta)
	handle_fov_change(delta)
	handle_zoom(delta)
	handle_lean(delta)
	move_and_slide()


func handle_effects(delta) -> void:
	if is_on_floor():
		var horizontal_velocity: Vector2 = Vector2(velocity.x, velocity.z)
		var speed_factor: float = horizontal_velocity.length() / BASE_WALK_SPEED
		foot_steps_animation_player.speed_scale = speed_factor
	else:
		foot_steps_animation_player.speed_scale = 0.0


func handle_falling(delta: float) -> void:
	if not on_floor_last_frame and is_on_floor():
		footsteps.play()
		camera_animation_player.play("land")
	on_floor_last_frame = is_on_floor()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


func handle_jump() -> void:
	if get_node_or_null("%jump") != null and %jump.is_triggered() and is_on_floor():
		velocity.y = jump_power
		footsteps.play()
		camera_animation_player.play("jump")


func handle_crouch(delta: float) -> void:
	var crouch_pressed: bool = get_node_or_null("%crouch") != null and %crouch.is_triggered()
	if toggle_crouch:
		if crouch_pressed:
			toggle_crouch_state()
	else:
		if crouch_pressed and not crouching:
			set_crouch(true)
		elif not crouch_pressed and crouching:
			set_crouch(false)
	crouch_released_last_frame = not crouch_pressed


func toggle_crouch_state() -> void:
	if not crouch_released_last_frame: return
	set_crouch(not crouching)


func set_crouch(enable: bool) -> void:
	if _crouch_tween != null:
		_crouch_tween.kill()
	if enable:
		_crouch_tween = create_tween()
		_crouch_tween.tween_property(self, "scale", crouch_height * Vector3.ONE, crouch_time)
	elif not ceiling.is_colliding():
		_crouch_tween = create_tween()
		_crouch_tween.tween_property(self, "scale", full_height * Vector3.ONE, crouch_time)


func set_movement_speed() -> void:
	if get_node_or_null("%sprint") != null and %sprint.is_triggered() and not disable_sprint:
		speed = sprint_speed
	else:
		speed = walk_speed
	
	if crouching:
		speed = crouch_speed
	footsteps.volume_linear = speed / walk_speed


func look_around() -> void:
	if lock_camera: return
	head.rotate_y(look_control.value_axis_2d().x * mouse_sensitivity)
	neck.rotate_x(look_control.value_axis_2d().y * mouse_sensitivity)
	neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-60), deg_to_rad(60))


func handle_movement(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector3 = move_control.value_axis_3d()
	
	var direction: Vector3 = (head.transform.basis * transform.basis * input_dir).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)


func handle_head_bob(delta: float) -> void:
	bob_time += delta * velocity.length() * float(is_on_floor())
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(bob_time * BOB_FREQ) * head_bob_strength
	pos.x = cos(bob_time * BOB_FREQ / 2) * head_bob_strength
	neck.transform.origin =  pos


func handle_fov_change(delta: float) -> void:
	var velocity_clamped: float = clamp(Vector2(velocity.x, velocity.z).length(), 0.5, sprint_speed * 2)
	var target_fov: float = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


func handle_zoom(delta: float) -> void:
	if get_node_or_null("%zoom") == null: return
	var target_fov: float = camera.fov * .33 if %zoom.is_triggered() else camera.fov
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


func handle_lean(delta: float) -> void:
	if get_node_or_null("%lean") == null: return
	var lean_control: GameControl = %lean
	var lean_value = lean_control.value()
	
	var lean_target_position = Vector3(
		lean_value * camera_lean_position.x,
		camera_base_position.y if lean_value == 0 else camera_lean_position.y,
		camera_base_position.z
	)
	camera.position = lerp(camera.position, lean_target_position, LEAN_SPEED)


func attach_to_hand(body: RigidBody3D) -> void:
	body.global_position = %RayCast3D.to_global(%RayCast3D.target_position)
	generic_6dof_joint_3d.node_b = body.get_path()


func detach_from_hand() -> void:
	generic_6dof_joint_3d.node_b = ""


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if %look == null:
		warnings.append("Add a unique named 'look' PlayerControl child to the player")
	if %move == null:
		warnings.append("Add a unique named 'move' PlayerControl child to the player")
	return warnings
