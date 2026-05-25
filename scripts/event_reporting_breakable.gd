@tool
class_name EventReportingBreakable extends Breakable

func _exit_tree() -> void:
	if EventTracker.instance:
		EventTracker.instance.send("broken_" + key)
