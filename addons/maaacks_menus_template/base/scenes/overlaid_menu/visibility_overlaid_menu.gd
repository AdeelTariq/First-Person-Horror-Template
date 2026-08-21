@tool
class_name VisibilityOverlaidMenu extends OverlaidMenu


func show_menu() -> void:
	if visible: return
	show()
	_on_start()


func hide_menu() -> void:
	_on_close()
	hide()


func _enter_tree() -> void:
	pass # override to do nothing


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		hide_menu()
		get_viewport().set_input_as_handled()
