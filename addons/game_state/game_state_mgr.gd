extends Node

const DEFAULT_SAVE_PATH : String = "user://game_state.json"
const FLAGS_PREFIX: StringName = "flag_"
const DOOR_KEY_PREFIX: StringName = "door_key_"

var _data: Dictionary

func _ready() -> void:
	_data = _load_file(DEFAULT_SAVE_PATH)


func saved_notes() -> Array[StringName]:
	var def: Array[StringName] = []
	return _data.get(&"notes", def)


func saved_notes_count() -> int:
	return saved_notes().size()


func save_note(key: StringName) -> void:
	var notes: Array = saved_notes()
	notes.append(key)
	_data[&"notes"] = notes


func add_door_key(key: StringName) -> void:
	var door_key: StringName = DOOR_KEY_PREFIX + key
	_data[door_key] = 1


func has_door_key(key: StringName) -> bool:
	var door_key: StringName = DOOR_KEY_PREFIX + key
	var door_key_value = _data.get(door_key, 0)
	return door_key_value > 0


func set_flag(flag: StringName) -> void:
	var flag_key: StringName = FLAGS_PREFIX + flag
	var flag_value = _data.get(flag_key, 0)
	_data[flag_key] = flag_value + 1


func has_flag(flag: StringName) -> bool:
	var flag_key: StringName = FLAGS_PREFIX + flag
	var flag_value = _data.get(flag_key, 0)
	return flag_value > 0


func clear_flag(flag: StringName) -> void:
	var flag_key: StringName = FLAGS_PREFIX + flag
	_data.erase(flag_key)


func set_data(key: StringName, data: Variant) -> void:
	_data.set(key, data)


func get_data(key: StringName, default: Variant) -> Variant:
	return _data.get(key, default)


func save() -> void:
	_save_file(DEFAULT_SAVE_PATH)


func _save_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_data))


func _load_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	
	var content: String = file.get_as_text()
	var parsed: Variant = JSON.parse_string(content)
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func clear_progress(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	DirAccess.remove_absolute(path)
