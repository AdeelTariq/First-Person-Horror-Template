extends BackBufferCopy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2.ZERO
	scale = Vector2.ONE
	print(get_viewport().get_visible_rect())
	rect = get_viewport().get_visible_rect()
