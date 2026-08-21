@tool
extends EditorPlugin

# Replace this value with a PascalCase autoload name, as per the GDScript style guide.
const peer_waiter = "PeerWaiter"
const timeout_await = "TimeoutAwait"

func _enable_plugin():
	# The autoload can be a scene or script file.
	add_autoload_singleton(peer_waiter, "res://addons/benbots-async-utils/peer_waiter.gd")
	add_autoload_singleton(timeout_await, "res://addons/benbots-async-utils/timeout_await.gd")


func _disable_plugin():
	remove_autoload_singleton(peer_waiter)
	remove_autoload_singleton(timeout_await)
