@tool
extends EditorPlugin

const AUTOLOAD_NAME = "co"
const SCENE_PATH = "res://addons/co/co.gd"

func _enter_tree() -> void:
	add_custom_type("Co", "Node", preload("uid://bjkb7sfgdaofj"), preload("uid://db5je0u1flhk1"))
	add_custom_type("CancelableCo", "Co", preload("uid://c4y2svcisccox"), preload("uid://db5je0u1flhk1"))
	add_autoload_singleton(AUTOLOAD_NAME, SCENE_PATH)


func _exit_tree() -> void:
	remove_custom_type("Co")
	remove_custom_type("CancelableCo")
	remove_autoload_singleton(AUTOLOAD_NAME)
