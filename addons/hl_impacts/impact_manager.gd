@tool
class_name ImpactManager extends Node

@export var surfaces: Dictionary[String, SurfaceType]

func spawn(surface: String, pos: Vector3, normal: Vector3):
	var surface_data: SurfaceType = surfaces.get(surface, surfaces["default"])
	
	if surface_data.impact_fx:
		var fx: Node3D = surface_data.impact_fx.instantiate()
		get_tree().current_scene.add_child(fx)
		fx.global_position = pos
		# orient to surface
		fx.look_at(pos + normal, Vector3.UP)
	
	if surface_data.decal:
		var decal: Node3D = surface_data.decal.instantiate()
		get_tree().current_scene.add_child(decal)
		decal.global_position = pos
		# orient to surface
		decal.look_at(pos + normal, Vector3.UP)
		decal.rotation_degrees += Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-90, 90))
	
	if surface_data.impact_sound:
		var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		player.bus = "SFX"
		player.stream = surface_data.impact_sound
		get_tree().current_scene.add_child(player)
		player.global_position = pos
		player.pitch_scale = randf_range(0.8, 1.2)
		player.play()
		await player.finished
		player.queue_free()


func get_surface_names() -> PackedStringArray:
	return surfaces.keys()
