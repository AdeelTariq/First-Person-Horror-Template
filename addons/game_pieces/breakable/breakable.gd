@tool
class_name Breakable extends Node

static var Meta: String = "breakable"

@export var max_health: int = 3
@export var pieces_despawn_time: int = 30
@export var pieces: PackedScene
@export var drops: Array[PackedScene] = []

var health: int

func _ready() -> void:
	health = max_health
	get_parent().set_meta(Meta, self)


func apply_damage(impact_force: float, normal: Vector3) -> void:
	if health == 0: return
	var damage: float
	if impact_force < ImpactManager.MINIMUM_IMPACT_FORCE:
		damage = 0.0
	elif impact_force < ImpactManager.SLIGHT_IMPACT_FORCE:
		damage = 1.0
	else:
		damage = 5.0
	health = clamp(health - damage, 0, max_health)
	
	if health == 0:
		if impact_force < ImpactManager.HIT_IMPACT_FORCE:
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
		for drop: PackedScene in drops:
			var object: Node3D = drop.instantiate()
			get_parent().get_parent().add_child(object)
			_drop_object(object)
		get_parent().queue_free()


func _apply_impulse(global_position: Vector3, object: Node, strength: float, normal: Vector3) -> void:
	for child: Node in object.get_children():
		if child is RigidBody3D:
			var force_direction: Vector3 = ((child as RigidBody3D).get_child(0) as MeshInstance3D).get_aabb().position
			force_direction += Vector3(randf() * 0.1, randf() * 0.1, randf() * 0.1) # randomness
			force_direction += normal # align with hit normal
			force_direction = force_direction.normalized()
			(child as RigidBody3D).apply_impulse(force_direction * strength, global_position)
			_late_destroy((child as RigidBody3D))
		_apply_impulse(global_position, child, strength + 1. * randf(), normal)


func _late_destroy(object: RigidBody3D) -> void:
	var tween: Tween = object.create_tween().bind_node(object)
	tween.tween_interval(pieces_despawn_time + randi_range(0, pieces_despawn_time))
	tween.tween_property(object, "collision_layer", 0, 0.1)
	tween.set_parallel(true)
	tween.tween_property(object, "global_position:y", -0.2, 2.0).as_relative()
	tween.tween_property(object, "scale", Vector3.ONE * -0.5, 2.0).as_relative()
	tween.set_parallel(false)
	tween.tween_method(object.queue_free.unbind(1), 0, 1, 0.1)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if get_parent() is not PhysicsBody3D:
		warnings.append("Breakable must be a child of a PhysicsBody3D")
	return warnings


static func apply_damage_if_breakable(body: Node3D, impact_force: float, normal: Vector3) -> void:
	if body.has_meta(Breakable.Meta):
		var breakable: Breakable = body.get_meta(Breakable.Meta)
		breakable.apply_damage(impact_force, normal)


func _drop_object(object: Node3D) -> void:
	var space_state: PhysicsDirectSpaceState3D = get_tree().root.get_viewport().world_3d.direct_space_state
	var from = get_parent().global_position
	var to = from + Vector3.DOWN * 1000
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	# placing node at collision point so its lowest point is touching it, not origin
	var collision_point: Vector3 = result.position if result else from
	
	if object.has_method("get_aabb"):
		var aabb: AABB = object.get_aabb()
		object.global_transform.origin = collision_point + Vector3(0, aabb.size.y / 2, 0)
	else:
		object.global_transform.origin = collision_point
	object.global_position += Vector3(randf_range(-0.3, 0.3), 0, randf_range(-0.3, 0.3))
	object.global_rotation_degrees += Vector3(0, randf_range(-90, 90), 0)
