class_name Toast extends PanelContainer

@export var pinned: bool = false

@onready var toast_icon: TextureRect = %ToastIcon
@onready var toast_label: RichTextLabel = %ToastLabel
@onready var toast_sub_text: RichTextLabel = %ToastSubText



var tween: Tween

func show_toast(text: String, texture: Texture, sub_text: String, anim_duration: float) -> void:
	toast_icon.texture = texture
	toast_label.text = text
	toast_sub_text.text = sub_text
	modulate = Color.TRANSPARENT
	offset_transform_position.x -= 256
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "offset_transform_position:x", 0, anim_duration)
	tween.tween_property(self, "modulate", Color.WHITE, anim_duration)
	tween.set_parallel(false)
	if pinned: return
	tween.tween_interval(5)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, anim_duration)
	await tween.finished
	queue_free()


func refresh_toast(text: String, anim_duration: float) -> void:
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "offset_transform_position:x", 0, anim_duration / 2.0)
	tween.tween_property(self, "modulate", Color.WHITE, anim_duration / 2.0)
	tween.set_parallel(false)
	tween.tween_property(self, "offset_transform_scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.05)
	tween.tween_property(toast_label, "text", text, 0.1)
	tween.tween_interval(0.05)
	tween.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SPRING)
	if pinned: return
	tween.tween_interval(5)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, anim_duration)
	await tween.finished
	queue_free()


func remove_toast(anim_duration: float) -> void:
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, anim_duration)
	await tween.finished
	queue_free()
