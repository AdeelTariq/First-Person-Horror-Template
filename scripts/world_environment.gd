extends WorldEnvironment


func _ready() -> void:
	environment.volumetric_fog_enabled = PlayerConfig.get_config("VideoSettings", "VolumetricFog", true)
	environment.glow_enabled = PlayerConfig.get_config("VideoSettings", "Bloom", true)
	if not PlayerConfig.get_config("VideoSettings", "Brightness"): return
	environment.tonemap_exposure = PlayerConfig.get_config("VideoSettings", "Brightness")


func _process(_delta: float) -> void:
	environment.volumetric_fog_enabled = PlayerConfig.get_config("VideoSettings", "VolumetricFog", true)
	environment.glow_enabled = PlayerConfig.get_config("VideoSettings", "Bloom", true)
	if not PlayerConfig.get_config("VideoSettings", "Brightness"): return
	environment.tonemap_exposure = PlayerConfig.get_config("VideoSettings", "Brightness")
	
