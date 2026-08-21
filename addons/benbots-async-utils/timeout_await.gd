extends Node
class_name TimeoutAwaitGlobal

func on(c: Callable, sig: BufferedSignal, wait_time := 1.0):
	return await TimeoutAwaiter.new().on(c, get_tree().create_timer(wait_time), sig, get_tree())
