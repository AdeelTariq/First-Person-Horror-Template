@tool
extends EditorPlugin

const OUTPUT_FILE := "res://project_info.md"

func _enter_tree():
	scene_saved.connect(_on_scene_saved)
	_generate_report()

func _exit_tree():
	if scene_saved.is_connected(_on_scene_saved):
		scene_saved.disconnect(_on_scene_saved)

func _on_scene_saved(_scene: String):
	_generate_report()

func _generate_report():
	var report := []

	report.append("# Canvas Layer Report")
	report.append("")
	report.append("| Layer | Layer Sort |")
	report.append("|-------|------------|")

	var dir := DirAccess.open("res://")
	if dir:
		_scan_directory("res://", report)

	var file := FileAccess.open(OUTPUT_FILE, FileAccess.WRITE)
	if file:
		file.store_string("\n".join(report))
		file.close()

func _scan_directory(path: String, report: Array):
	var dir := DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()

	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break

		if file_name.begins_with("."):
			continue

		var full_path := path.path_join(file_name)

		if dir.current_is_dir():
			_scan_directory(full_path, report)
		elif file_name.ends_with(".tscn"):
			_scan_scene(full_path, report)

	dir.list_dir_end()

func _scan_scene(scene_path: String, report: Array):
	var file := FileAccess.open(scene_path, FileAccess.READ)
	if file == null:
		return

	var in_canvas_layer := false
	var node_name := ""
	var parent := ""
	var layer := 0

	while not file.eof_reached():
		var line := file.get_line().strip_edges()

		if line.begins_with("[node "):
			if in_canvas_layer:
				report.append("| %s | %d |" % [
					scene_path.get_file().replace(".tscn", "").capitalize(),
					layer
				])

			in_canvas_layer = false
			layer = 0

			if line.contains('type="CanvasLayer"'):
				in_canvas_layer = true
				node_name = _extract(line, 'name="', '"')
				parent = _extract(line, 'parent="', '"')

		elif in_canvas_layer and line.begins_with("layer"):
			var parts := line.split("=")
			if parts.size() == 2:
				layer = parts[1].strip_edges().to_int()

	if in_canvas_layer:
		report.append("| %s | %d |" % [
			scene_path.get_file().replace(".tscn", "").capitalize(),
			layer
		])


func _extract(text: String, start: String, end: String) -> String:
	var i := text.find(start)
	if i == -1:
		return ""

	i += start.length()

	var j := text.find(end, i)
	if j == -1:
		return ""

	return text.substr(i, j - i)
