extends RefCounted
class_name BufferedSignal

var sig: Signal

var data: Array[Variant]

func _handler(...args):
	data.push_back(args)

func _init(m_signal: Variant, flags := 0):
	if m_signal == null:
		return
	sig = m_signal
	m_signal.connect(_handler,
		flags
	)

func clear() -> void:
	data.clear()

func listen_peek() -> Variant:
	if len(data) > 0:
		return data[0]
	else:
		return await sig

func check_for(thing: Variant) -> Variant:
	var idx := data.find(thing)
	if len(data) == 0:
		await sig

	if idx != -1:
		return data.pop_at(idx)
	return null

func listen(pop := true) -> Variant:
	if len(data) > 0:
		if pop:
			return data.pop_front()
		else:
			return data[0]
	else:
		await sig
		return data.pop_front()

static func all(signals: Array[BufferedSignal]) -> Array:
	var response: Array
	for s in signals:
		response.push_back(await s.listen())
	
	# kind of a hack to fix memory leaks
	# this is caused by a circular reference that I haven't 
	# had to fix yet, since this solves it
	for s in signals:
		s.unreference()

	return response
