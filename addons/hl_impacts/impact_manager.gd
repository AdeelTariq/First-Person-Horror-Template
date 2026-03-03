@tool
class_name ImpactManager extends Node

const MINIMUM_IMPACT_FORCE: float = 1.0
const SLIGHT_IMPACT_FORCE: float = 8.0
const HIT_IMPACT_FORCE: float = 20.0

@export var surfaces: Dictionary[String, SurfaceType]

func spawn(body: Node3D, pos: Vector3, normal: Vector3, impulse: Vector3):
	var impulse_strength: float = impulse.length()
	if impulse_strength < MINIMUM_IMPACT_FORCE: return
	var surface: String = "default"
	if body.has_meta("surface_type"):
		surface = body.get_meta("surface_type")
		
	var surface_data: SurfaceType = surfaces.get(surface, surfaces["default"])
	
	if impulse_strength > SLIGHT_IMPACT_FORCE:
		if surface_data.impact_fx:
			var fx: Node3D = surface_data.impact_fx.instantiate()
			get_tree().current_scene.add_child(fx)
			fx.global_position = pos
			# orient to surface
			fx.look_at(pos + normal, Vector3.UP)

		if surface_data.decal:
			var decal: Node3D = surface_data.decal.instantiate()
			body.add_child(decal)
			decal.global_position = pos
			decal.scale = Vector3.ONE / body.scale
			# orient to surface
			decal.look_at(pos + normal, Vector3.UP)
			decal.rotation_degrees += Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-90, 90))
	
	var sound: AudioStream = null
	if impulse_strength > HIT_IMPACT_FORCE:
		if surface_data.crash_sound: sound = surface_data.crash_sound
	elif impulse_strength > SLIGHT_IMPACT_FORCE:
		if surface_data.hit_sound: sound = surface_data.hit_sound
	else:
		if surface_data.tap_sound: sound = surface_data.tap_sound
	
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.bus = "SFX"
	player.stream = sound
	get_tree().current_scene.add_child(player)
	player.global_position = pos
	player.pitch_scale = randf_range(0.8, 1.2)
	player.play()
	await player.finished
	player.queue_free()

func get_surface_names() -> PackedStringArray:
	return surfaces.keys()
