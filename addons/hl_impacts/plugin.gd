@tool
extends EditorPlugin

const AUTOLOAD_NAME = "ImpactMgr"
const SCENE_PATH = "res://addons/hl_impacts/impact_manager.tscn"
const SCENE_NAME = "impact_manager.tscn"
const PROJECT_SETTINGS_PATH = "impact_manager/"

var inspector


func _enable_plugin() -> void:
	_show_plugin_setup()


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)


func _enter_tree() -> void:
	var has_setting: bool = ProjectSettings.has_setting(PROJECT_SETTINGS_PATH + "auto_load_path")
	if has_setting and FileAccess.file_exists(ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "auto_load_path") + SCENE_NAME):
		inspector = SurfaceTypeInspector.new(ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "auto_load_path") + SCENE_NAME)
		add_inspector_plugin(inspector)


func _exit_tree() -> void:
	remove_inspector_plugin(inspector)


func _show_plugin_setup() -> void:
	var has_setting: bool = ProjectSettings.has_setting(PROJECT_SETTINGS_PATH + "auto_load_path")
	if has_setting and FileAccess.file_exists(ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "auto_load_path") + SCENE_NAME):
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
			create_inherited_scene(SCENE_PATH, dir + SCENE_NAME)
			EditorInterface.save_all_scenes()
			EditorInterface.get_resource_filesystem().scan()
			_wait_for_scan_and_complete(dir)
	)


func create_inherited_scene(base_path: String, new_path: String) -> void:
	# open the base scene in the editor
	EditorInterface.open_scene_from_path(base_path, true)
	# save as inherited scene
	EditorInterface.save_scene_as(new_path) # true = inherited


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
	
	inspector = SurfaceTypeInspector.new(scene_path)
	add_inspector_plugin(inspector)


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
