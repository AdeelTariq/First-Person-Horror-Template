@tool 
extends Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	GamePiecesEventBus.camera_lock_requested.connect(_on_camera_lock_requested)


func _on_camera_lock_requested(enable: bool) -> void:
	lock_camera = enable
