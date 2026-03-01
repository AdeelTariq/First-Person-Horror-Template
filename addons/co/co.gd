class_name Co
extends Node


enum TickMode { PROCESS, PHYSICS_PROCESS, MANUAL }

signal _ticked()

@export var tick_mode: TickMode = TickMode.PROCESS:
	get: return tick_mode
	set(value):
		if value == tick_mode:
			return
		tick_mode = value
		if is_node_ready():
			set_process(tick_mode == TickMode.PROCESS)
			set_physics_process(tick_mode == TickMode.PHYSICS_PROCESS)

var delta: float
var time: float
var _routines: Array[Routine]


func _ready() -> void:

	set_process(tick_mode == TickMode.PROCESS)
	set_physics_process(tick_mode == TickMode.PHYSICS_PROCESS)


func _notification(what: int) -> void:

	if what == NOTIFICATION_PREDELETE:
		for routine in _routines:
			if routine:
				routine.free()
		_routines.clear()


func _process(p_delta: float) -> void:

	tick(p_delta)


func _physics_process(p_delta: float) -> void:

	tick(p_delta)


func tick(p_delta: float) -> void:

	delta = p_delta
	time += p_delta

	for i in range(_routines.size() - 1, -1, -1):
		var routine := _routines[i]
		if routine.step(delta):
			routine.free()
			_routines.remove_at(i)

	_ticked.emit()


func one_frame() -> Signal:

	return _ticked


func frames(n: int) -> void:

	var r := FramesRoutine.new()
	r.frames_left = n
	_routines.push_front(r)
	while r:
		await _ticked


func seconds(s: float) -> void:

	var r := SecondsRoutine.new()
	r.seconds_left = s
	_routines.push_front(r)
	while r:
		await _ticked


func all(items: Array) -> void:

	var r := AllRoutine.new()
	r.items_left = items.size()
	for item in items:
		r._run_item(item)
	_routines.push_front(r)
	while r:
		await _ticked


func any(items: Array) -> void:

	var r := AnyRoutine.new()
	for item in items:
		r._run_item(item)
	_routines.push_front(r)
	while r:
		await _ticked


func until(cond: Callable) -> void:

	while cond and not cond.call():
		await _ticked


func until_not(cond: Callable) -> void:

	while cond and cond.call():
		await _ticked


func do(action: Callable) -> void:

	await action.call()
	await _ticked


func listen(sig: Signal) -> void:

	await sig
	await _ticked


func forever() -> void:

	while true:
		await _ticked


class Routine extends Object:

	# VIRTUAL
	func step(_delta: float) -> bool:

		return false


class FramesRoutine extends Routine:

	var frames_left: int

	func step(_delta: float) -> bool:

		frames_left -= 1
		return frames_left <= 0


class SecondsRoutine extends Routine:

	var seconds_left: float

	func step(delta: float) -> bool:

		seconds_left -= delta
		return seconds_left <= 0


class AllRoutine extends Routine:

	var items_left: int

	func step(_delta: float) -> bool:

		return items_left <= 0

	func _run_item(item) -> void:

		if item is Callable:
			await item.call()
		elif item is Signal:
			await item
		items_left -= 1


class AnyRoutine extends Routine:

	var done: bool

	func step(_delta: float) -> bool:

		return done

	func _run_item(item) -> void:

		if item is Callable:
			await item.call()
		elif item is Signal:
			await item
		done = true
