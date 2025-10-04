extends PauseMenu

@onready var back_button: Button = %BackButton
@onready var options_container: MarginContainer = %OptionsContainer

func _ready() -> void:
	super._ready()
	back_button.pressed.connect(close_options_menu)
	var options_scene: Control = options_packed_scene.instantiate()
	options_container.add_child(options_scene)


func open_options_menu() -> void:
	back_button.show()
	options_container.show()
	_disable_focus.call_deferred()


func close_options_menu() -> void:
	back_button.hide()
	options_container.hide()
	_enable_focus.call_deferred()
