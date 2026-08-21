extends Node
class_name RPCPeerWaiter 

signal got_message(msg: String)

var buffered_signal := BufferedSignal.new(got_message)

func confirm(id: String):
	_confirm.rpc_id(1, id)

@rpc("any_peer", "call_remote", "reliable")
func _confirm(id: String) -> void:
	got_message.emit(id)

func on(c: Callable, num: int = 1):
	if not multiplayer.is_server():
		return

	# This is used to try and see if the function is an rpc function
	if not c.is_custom():
		await c.call()
		return
	if c.get_argument_count() == 0:
		push_error("Invalid function args for peer waiter for function %s. %d" % [c.get_method(), c.get_argument_count()])
		return

	var id := UUID.v4()
	var callable := c.rpc.bind(id)

	return await TimeoutAwait.on(callable, buffered_signal, 1.0)
