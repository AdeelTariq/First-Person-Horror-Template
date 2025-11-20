class_name TaloEvents extends Node

func _ready() -> void:
	if not PlayerConfig.has_section_key("talo", "identity"):
		PlayerConfig.set_config("talo", "identity", Talo.players.generate_identifier())
	var identity: String = PlayerConfig.get_config("talo", "identity", "")
	Talo.players.identify("Player", identity)
