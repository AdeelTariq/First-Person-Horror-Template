@tool
class_name EventReportingBreakable extends Breakable

func _exit_tree() -> void:
		EventBus.send("broken_" + key)
