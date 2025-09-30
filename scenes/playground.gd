extends Node3D

@export var mapping_context: GUIDEMappingContext

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GUIDE.enable_mapping_context(mapping_context)
