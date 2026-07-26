extends Node

signal event_sent(event: String, props: Dictionary)


func send(event: String, props: Dictionary = {}) -> void:
	event_sent.emit(event, props)
	if Talo.has_identity(): 
		Talo.events.track(event, props)
		Talo.events.flush()
	if OS.is_debug_build(): print(event, props)
