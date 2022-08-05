extends ObserverBase
class_name Observer

var _handler_on_next : Callable
var _handler_on_error : Callable
var _handler_on_completed : Callable
var _is_stopped : bool

func _init(
	on_next : Callable = func(i): return,
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return):
		self._is_stopped = false
		self._handler_on_next = on_next
		self._handler_on_error = on_error
		self._handler_on_completed = on_completed

func on_next(i):
	if not self._is_stopped:
		self._on_next_core(i)

func _on_next_core(i):
	self._handler_on_next.call(i)

func on_error(e):
	if not self._is_stopped:
		self._is_stopped = true
		self._on_error_core(e)

func _on_error_core(e):
	self._handler_on_error.call(e)

func on_completed():
	if not self._is_stopped:
		self._is_stopped = true
		self._on_completed_core()

func _on_completed_core():
	self._handler_on_completed.call()

func dispose():
	self._is_stopped = true

func fail(e):
	if not self._is_stopped:
		self._is_stopped = true
		self._on_error_core(e)
		return true
	return false

func throw(e):
	print_stack()
	push_error(e)
	return e

func to_notifier() -> Callable:
	return func(notifier : Notification): 
		return notifier.accept(self)

func as_observer() -> ObserverBase:
	return Observer.new(self.on_next, self.on_error, self.on_completed)
