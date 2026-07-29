extends Node

@export var setting_section: String
@export var setting_key: String
@export var setting_default: Variant
@export var property_to_effect: String
@export var other_settings: Array[SettingToApply]

func _ready() -> void:
	set_indexed(property_to_effect, PlayerConfig.get_config(setting_section, setting_key, setting_default))
	for setting: SettingToApply in other_settings:
		set_indexed(setting.property_to_effect, PlayerConfig.get_config(setting.setting_section, setting.setting_key, setting.setting_default))


func _process(_delta: float) -> void:
	set_indexed(property_to_effect, PlayerConfig.get_config(setting_section, setting_key, setting_default))
	for setting: SettingToApply in other_settings:
		set_indexed(setting.property_to_effect, PlayerConfig.get_config(setting.setting_section, setting.setting_key, setting.setting_default))
