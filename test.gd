@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var icon: Texture = InputIconMapperGlobal.get_icon(InputEventMouseMotion.new())
	var _size = 32
	print("[img width=%d]%s[/img]" % [_size, icon.resource_path])
