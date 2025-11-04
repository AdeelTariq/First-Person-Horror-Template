@tool
class_name CollisionSoundPlayer extends AudioStreamPlayer3D

@export var sounds_per_velocity: Dictionary[int, AudioStream]

@onready var velocities: Array[int] = sounds_per_velocity.keys()

func _ready() -> void:
	velocities.sort()
	velocities.reverse()
	max_polyphony = 3
	get_parent().body_entered.connect(play_on_collision)
	get_parent().max_contacts_reported = 1
	get_parent().contact_monitor = true


func play_on_collision(_body):
	for v in velocities:
		if get_parent().linear_velocity.length() > v:
			stream = sounds_per_velocity[v]
			pitch_scale = randf_range(0.8, 1.2)
			play()
			break


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if not get_parent() is RigidBody3D:
		warnings.append("Parent object must be a RigidBody3D")
	return warnings
