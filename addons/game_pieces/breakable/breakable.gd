@tool
class_name Breakable extends Node

static var Meta: String = "breakable"

@export var max_health: int = 3

@export var pieces: PackedScene

var health: int

func _ready() -> void:
	health = max_health
	get_parent().set_meta(Meta, self)


func apply_damage(impact_force: float, normal: Vector3) -> void:
	health = clamp(health - 1, 0, max_health)
	
	if health == 0:
		ImpactMgr.spawn(get_parent(), 
			Vector3.ZERO, # zero because object will be destroyed and
			Vector3.ZERO, # we don't care about decal or forces
			Vector3.ONE * ImpactManager.HIT_IMPACT_FORCE
		)
		var instance: Node3D = pieces.instantiate()
		get_parent().get_parent().add_child(instance)
		instance.global_position = get_parent().global_position
		instance.global_rotation = get_parent().global_rotation
		_apply_impulse(instance.global_position, instance, impact_force + 1. * randf(), normal)
		get_parent().queue_free()


func _apply_impulse(global_position: Vector3, object: Node, strength: float, normal: Vector3) -> void:
	for child: Node in object.get_children():
		if child is RigidBody3D:
			var force_direction: Vector3 = ((child as RigidBody3D).get_child(0) as MeshInstance3D).get_aabb().position
			force_direction += Vector3(randf() * 0.1, randf() * 0.1, randf() * 0.1) # randomness
			force_direction += normal # align with hit normal
			force_direction = force_direction.normalized()
			(child as RigidBody3D).apply_impulse(force_direction * strength, global_position)
		_apply_impulse(global_position, child, strength + 1. * randf(), normal)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not PhysicsBody3D:
		warnings.append("Breakable must be a child of a PhysicsBody3D")
	return warnings


static func apply_damage_if_breakable(body: Node3D, impact_force: float, normal: Vector3) -> void:
	if body.has_meta(Breakable.Meta):
		var breakable: Breakable = body.get_meta(Breakable.Meta)
		breakable.apply_damage(impact_force, normal)
