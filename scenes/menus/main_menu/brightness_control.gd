extends CenterContainer

@export var world_env: Environment

@onready var h_slider: HSlider = %HSlider
@onready var button: Button = %Button

signal done()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	await get_tree().process_frame
	@warning_ignore("untyped_declaration")
	var brightness = PlayerConfig.get_config("VideoSettings", "Brightness")
	if brightness:
		done.emit()
		queue_free()
		return
	
	show()
	h_slider.value = world_env.tonemap_exposure
	button.pressed.connect(func() -> void: 
		EventTracker.instance.send("brightness_set", {"value": str(h_slider.value)})
		hide()
		done.emit()
	)


func _process(_delta: float) -> void:
	if not visible: return
	PlayerConfig.set_config("VideoSettings", "Brightness", h_slider.value)
