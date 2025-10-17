@tool
extends EditorPlugin

const AUTOLOAD_NAME = "SoundFxMgr"
const SCENE_PATH = "res://addons/sound_fx_manager/sound_fx_mgr.tscn"
const SCENE_NAME = "sound_fx_mgr.tscn"
const FILE_NAME = "sounds.gd"
const PROJECT_SETTINGS_PATH = "sound_fx_manager/"

func _enable_plugin() -> void:
	_show_plugin_setup()


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)


func _enter_tree() -> void:
	scene_saved.connect(_scene_saved)


func _scene_saved(scene: String):
	var auto_load_path: String = ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "auto_load_path")
	var scene_path = auto_load_path + SCENE_NAME
	var file_path = auto_load_path + FILE_NAME
	if scene == scene_path:
		await get_tree().create_timer(1).timeout
		
		var packed_scene: PackedScene = load(scene_path)
		var instance: Node = packed_scene.instantiate()
		var nodes: Array = instance.get_children()
		
		var sounds_string: String = "\n".join(
			nodes.map(
			func(node: Node) -> String: 
				var node_name: String = node.name
				var field_name: String = to_identifier(node_name)
				if field_name != node_name:
					while nodes.any(func(n: Node) -> bool: return n.name == field_name):
						field_name = "_" + field_name
				
				return 'static var {name}: NodePath = ^"{value}"'.format({
					"name": field_name,
					"value": node_name,
					})
				)
			)
		
		var script_content: String = \
	"""class_name Sfx extends RefCounted

{sounds}

""".format({"sounds": sounds_string})

		var script: GDScript = GDScript.new()
		script.source_code = script_content
		ResourceSaver.save(script, file_path)
		ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_REPLACE)
		instance.queue_free()



func _exit_tree() -> void:
	scene_saved.disconnect(_scene_saved)


func _show_plugin_setup() -> void:
	if ProjectSettings.has_setting(PROJECT_SETTINGS_PATH + "auto_load_path"):
		_complete(ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "auto_load_path"))
		return
	var dialog: FileDialog = FileDialog.new()
	dialog.mode_overrides_title = false
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.ok_button_text = "Select Current Folder"
	dialog.title = "Select a Destination for SoundFx Scene"
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	dialog.visible = true
	dialog.exclusive = false
	dialog.size = Vector2(1024, 640)
	add_child(dialog)
	dialog.dir_selected.connect(
		func(dir: String) -> void: 
			if not dir.ends_with("/"):
				dir += "/"
			var file_object = load(SCENE_PATH)
			ResourceSaver.save(file_object, dir + SCENE_NAME, ResourceSaver.FLAG_CHANGE_PATH)
			EditorInterface.save_all_scenes()
			EditorInterface.get_resource_filesystem().scan()
			_wait_for_scan_and_complete(dir)
	)


func _wait_for_scan_and_complete(target_path : String) -> void:
	var timer: Timer = Timer.new()
	var callable := func():
		if EditorInterface.get_resource_filesystem().is_scanning(): return
		timer.stop()
		_complete(target_path)
		timer.queue_free()
	timer.timeout.connect(callable)
	add_child(timer)
	timer.start(0.25)


func _complete(path: String) -> void:
	var scene_path: String = path + SCENE_NAME
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + "auto_load_path", path)
	add_autoload_singleton(AUTOLOAD_NAME, scene_path)
	ProjectSettings.save()
	EditorInterface.open_scene_from_path(scene_path)
	_scene_saved(scene_path)


func to_identifier(input: String) -> String:
	var result = ""
	for c: String in input:
		if is_valid_identifier_char(c):
			result += c
		else:
			result += "_"
	if result.length() > 0 and result[0].is_valid_int():
		result = "_" + result
	return result

func is_valid_identifier_char(c: String) -> bool:
	return c.is_valid_int() or c.is_valid_ascii_identifier() or c == "_"
