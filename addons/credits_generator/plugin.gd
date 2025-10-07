@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_tool_menu_item("Generate Credits", generate_credits)


func _exit_tree() -> void:
	remove_tool_menu_item("Generate Credits")


func generate_credits() -> void:
	Generator.new().generate()
