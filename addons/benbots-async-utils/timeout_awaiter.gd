extends RefCounted
class_name TimeoutAwaiter

var got_message := false

func on(c: Callable, timer: SceneTreeTimer, buffered_signal: BufferedSignal, tree: SceneTree):
	var success := DummySignal.new()
	var cancel := DummySignal.new()

	var signal_data = null

	c.call()

	# So the idea here is that every frame we check to see if either we got a message with our Id
	# or the timer ran out. That way we don't keep this coroutine locked up forever
	var confirm_func := func():
		var cancel_signal := BufferedSignal.new(cancel.dummy)
		while not got_message and len(cancel_signal.data) == 0:
			var data := (await buffered_signal.listen(false))
			if not data.is_empty() and data[0] != null:
				signal_data = buffered_signal.data.pop_front()
				got_message = true
				success.dummy.emit()
				return

			await tree.process_frame

	confirm_func.call()
	timer.timeout.connect(func():
		if self.got_message:
			return
		print_debug("%s timedout" % c.get_method())
		success.dummy.emit()
		cancel.dummy.emit()
	, CONNECT_ONE_SHOT)

	await success.dummy
	return signal_data
