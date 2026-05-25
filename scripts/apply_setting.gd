extends Node

@export var setting_section: String
@export var setting_key: String
@export var setting_default: Variant
@export var property_to_effect: String

func _ready() -> void:
	set(property_to_effect, PlayerConfig.get_config(setting_section, setting_key, setting_default))


func _process(_delta: float) -> void:
	set(property_to_effect, PlayerConfig.get_config(setting_section, setting_key, setting_default))
