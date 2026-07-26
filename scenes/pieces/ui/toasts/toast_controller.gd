extends CanvasLayer

@export var toast_scene: PackedScene
@export var anim_duration: float = 0.3

@onready var container: VBoxContainer = %Container

var _queue: Array = []
var _running: bool = false


func show_toast(text: String, texture: Texture = null, sub_text: String = "") -> void:
	_enqueue(anim_duration, _new_toast.bind(text, texture, sub_text))


func add_pinned_toast(key: String, text: String, texture: Texture = null, sub_text: String = "") -> void:
	_enqueue(anim_duration, _new_toast_with_key.bind(key, text, texture, sub_text))


func remove_pinned_toast(key: String) -> void:
	var same_key_toasts: Array = container.get_children().filter(
		func(t: Toast) -> bool: return t.get_meta("key", null) == key
	)
	if same_key_toasts.size() > 0:
		var toast: Toast = same_key_toasts[0]
		toast.remove_toast(anim_duration)


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
	_new_toast_with_key(key, text, texture, sub_text, false)


func _new_toast_with_key(key: String, text: String, texture: Texture, sub_text: String, pinned: bool = true) -> void:
	var same_key_toasts: Array = container.get_children().filter(
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
	toast.pinned = pinned
	container.add_child(toast)
	var first_non_pinned_index: int = 0
	for i: int in range(container.get_child_count()):
		if (container.get_child(i) as Toast).pinned: continue
		first_non_pinned_index = i
		break
	container.move_child(toast, first_non_pinned_index)
	toast.show_toast(text, texture, sub_text, anim_duration)
	toast.set_meta("key", key)
	toast.set_meta("key_count", 1)
	_animation_new_item()


func _animation_new_item() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel()
	for child: Control in container.get_children():
		if (child as Toast).pinned: continue
		var offset_y: float = child.size.y + container.get_theme_constant("separation")
		child.offset_transform_position.y = -offset_y
		tween.tween_property(child, "offset_transform_position:y", offset_y, anim_duration).as_relative()
	if not tween.has_tweeners(): tween.kill()
