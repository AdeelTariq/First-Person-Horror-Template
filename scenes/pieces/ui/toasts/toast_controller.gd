extends VBoxContainer

@export var toast_scene: PackedScene
@export var anim_duration: float = 0.3

var _queue: Array = []
var _running: bool = false

func _ready() -> void:
	show_toast("Toasting 1")
	show_toast("Toasting 1")
	show_toast("Toasting 1")
	show_toast("Toasting 1")
	show_toast("Toasting 2")
	show_toast("Toasting 3")
	show_toast("Toasting 4")
	show_toast("Toasting 5")
	show_toast("Toasting 6")
	show_toast("Toasting 7")
	await get_tree().create_timer(anim_duration * 10).timeout
	show_toast("Toasting 1")
	show_toast("Toasting 2")
	show_toast("Toasting 3")
	show_toast("Toasting 4")
	show_toast("Toasting 5")
	show_toast("Toasting 6")
	show_toast("Toasting 7")


func show_toast(text: String, texture: Texture = null, sub_text: String = "") -> void:
	_enqueue(anim_duration, _new_toast.bind(text, texture, sub_text))


func _enqueue(delay: float, callable: Callable) -> void:
	_queue.append({ "delay": delay, "callable": callable })
	if not _running:
		_process_queue()


func _process_queue() -> void:
	_running = true

	while _queue.size() > 0:
		var item: Dictionary = _queue.pop_front()

		var delay: float = item.delay
		var callable: Callable = item.callable
		await get_tree().create_timer(delay).timeout
		callable.call()

	_running = false



func _new_toast(text: String, texture: Texture, sub_text: String) -> void:
	var key: String = text + str(texture) + sub_text
	
	var same_key_toasts: Array = get_children().filter(
		func(t: Toast) -> bool: return t.get_meta("key", null) == key
	)
	if same_key_toasts.size() > 0:
		var old_toast: Toast = same_key_toasts[0]
		old_toast.set_meta("key_count", old_toast.get_meta("key_count", 1) + 1)
		old_toast.tween.kill()
		var new_text: String = "%s X%d" % [text, old_toast.get_meta("key_count", 1)]
		old_toast.refresh_toast(new_text, anim_duration)
		return

	var toast: Toast = toast_scene.instantiate()
	add_child(toast)
	move_child(toast, 0)
	toast.show_toast(text, texture, sub_text, anim_duration)
	toast.set_meta("key", key)
	toast.set_meta("key_count", 1)
	_animation_new_item()


func _animation_new_item() -> void:
	#await get_tree().process_frame
	var tween: Tween = create_tween()
	tween.set_parallel()
	for child: Control in get_children():
		var offset: float = child.size.y + get_theme_constant("separation")
		child.offset_transform_position.y = -offset
		tween.tween_property(child, "offset_transform_position:y", offset, anim_duration).as_relative()
