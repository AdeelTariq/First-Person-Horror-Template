class_name FirstTimeSetup extends Control

@export_file_path("*.tscn") var next_scene: String
@export var bg_music: AudioStream
@export var bg_music_player: AudioStreamPlayer

func _ready() -> void:
	if PlayerConfig.has_section("LaunchSetup"):
		get_tree().call_deferred("change_scene_to_file", next_scene)
		return
	else:
		SceneLoader.load_scene(next_scene, true)
	bg_music_player.stream = bg_music
	for child: Control in get_children():
		child.hide()
	if get_child_count() > 0:
		_fade_in(get_child(0))

func next() -> void:
	for i in range(get_child_count()):
		if not get_child(i).visible: continue
		_fade_out(get_child(i))
		if i < get_child_count() - 1:
			_fade_in(get_child(i + 1))
		else:
			_load_next_scene()
		break


func _load_next_scene() -> void:
	SceneLoader.change_scene_to_resource()
	PlayerConfig.set_config("LaunchSetup", "completed", true)


func _fade_out(control: Control) -> void:
	await create_tween().tween_property(control, "modulate:a", 0.0, 0.3).finished
	control.hide()


func _fade_in(control: Control) -> void:
	await get_tree().create_timer(0.3).timeout
	control.modulate.a = 0.0
	control.show()
	create_tween().tween_property(control, "modulate:a", 1.0, 0.3).finished


func audio_control_visibility_changed(audio_control: Control) -> void:
	bg_music_player.playing = audio_control.visible
