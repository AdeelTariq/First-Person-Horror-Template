class_name EventTracker extends Node

static var instance: EventTracker

func _init() -> void:
	instance = self


func send(event: String, props: Dictionary[String, String] = {}) -> void:
	if Talo.has_identity(): 
		Talo.events.track(event, props)
		Talo.events.flush()
	if OS.is_debug_build(): print(event, props)
