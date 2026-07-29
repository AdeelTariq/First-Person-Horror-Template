extends CenterContainer

@export var world_env: Environment

@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var button: Button = %Button
@onready var world_environment: WorldEnvironment = %WorldEnvironment

signal done()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_environment.environment.fog_enabled = false
	world_environment.environment.volumetric_fog_enabled = false
	world_environment.environment.glow_enabled = false
	button.pressed.connect(func() -> void: 
		EventBus.send("brightness_set", {"value": str(brightness_slider.value)})
		done.emit()
	)


func _process(_delta: float) -> void:
	if not visible: return
	PlayerConfig.set_config("VideoSettings", "Brightness", brightness_slider.value)
