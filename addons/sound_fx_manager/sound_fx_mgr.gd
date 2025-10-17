extends Node

func play_single(sound: NodePath, pitch : float = 1.0) -> void:
	var player: AudioStreamPlayer = get_node(sound)
	player.pitch_scale = pitch
	player.play()


func play_safe(sound: NodePath, pitch : float = 1.0) -> void:
	var player: AudioStreamPlayer = get_node(sound)
	if player.playing: return
	player.pitch_scale = pitch
	player.play()


func play(sound: NodePath, pitch : float = 1.0) -> void:
	var player: AudioStreamPlayer = get_node(sound).duplicate()
	add_child(player)
	player.pitch_scale = pitch
	player.play()
	await player.finished
	player.queue_free()


func play_random(group: StringName, pitch : float = 1.0) -> void:
	var node: Node = get_tree().get_nodes_in_group(group).pick_random()
	var player: AudioStreamPlayer = node.duplicate()
	add_child(player)
	player.pitch_scale = pitch
	player.play()
	await player.finished
	player.queue_free()


func play2D(sound: NodePath, position: Vector2, pitch : float = 1.0) -> void:
	var player: AudioStreamPlayer2D = get_node(sound).duplicate()
	add_child(player)
	player.pitch_scale = pitch
	player.position = position
	player.play()
	await player.finished
	player.queue_free()


func play3D(sound: NodePath, position: Vector3, pitch : float = 1.0) -> void:
	var player: AudioStreamPlayer3D = get_node(sound).duplicate()
	add_child(player)
	player.pitch_scale = pitch
	player.position = position
	player.play()
	await player.finished
	player.queue_free()


func play_random3D(group: StringName, position: Vector3, pitch : float = 1.0) -> void:
	var player: AudioStreamPlayer3D = get_tree().get_nodes_in_group(group).pick_random()
	add_child(player)
	player.pitch_scale = pitch
	player.position = position
	player.play()
	await player.finished
	player.queue_free()


func fade_in(sound: NodePath, duration: float, to_volume: int = 0) -> void:
	var player: AudioStreamPlayer = get_node(sound)
	player.play()
	player.volume_db = -80
	var tween: Tween = create_tween()
	@warning_ignore("return_value_discarded")
	tween.tween_property(get_node(sound), "volume_db", to_volume, duration)


func fade_out(sound: NodePath, duration: float) -> void:
	var tween: Tween = create_tween()
	@warning_ignore("return_value_discarded")
	tween.tween_property(get_node(sound), "volume_db", -80, duration)


func stop_playing(sound: NodePath) -> void:
	var player: AudioStreamPlayer = get_node(sound)
	if player.playing: player.stop()
