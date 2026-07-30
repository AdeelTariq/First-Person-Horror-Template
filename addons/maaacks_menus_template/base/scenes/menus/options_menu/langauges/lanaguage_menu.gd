class_name LanguageMenu
extends Control

@export var language_button_scene : PackedScene
@export var languages : Array[String]

signal language_selected()

func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	_add_language_buttons()


func _add_language_buttons() -> void:
	#var locales: Array = ["zh", "ur", "en", "fr", "es"]
	var locales: Array = TranslationServer.get_loaded_locales()
	var default_locale: String = PlayerConfig.get_config("LOCALE", "language", OS.get_locale())
	TranslationServer.set_locale(default_locale)
	locales.sort_custom(func(l1: String, l2: String) -> bool: return default_locale.contains(l1))
	for locale in locales:
		var translation = TranslationServer.get_translation_object(locale)
		var locale_name: String
		if translation:
			locale_name = translation.get_message("LANGUAGE_NAME")
		else:
			locale_name = TranslationServer.get_language_name(locale)
		_add_language_button(locale_name, locale, default_locale.contains(locale))

func _add_language_button(locale_name: String, locale: String, preselect: bool) -> void:
	var button: Button = language_button_scene.instantiate()
	%LanguageContainer.add_child(button)
	button.text = locale_name
	if preselect: button.grab_focus()
	button.pressed.connect(set_language.bind(locale))


func set_language(locale: String) -> void:
	TranslationServer.set_locale(locale)
	PlayerConfig.set_config("LOCALE", "language", locale)
	language_selected.emit()
