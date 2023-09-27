extends ObserverBase
class_name Observer

var _handler_on_next : Callable
var _handler_on_error : Callable
var _handler_on_completed : Callable
var is_stopped : bool

var this : Observer

func _init(
	on_next_ : Callable = GDRx.basic.noop,
	on_error_ : Callable = GDRx.basic.noop,
	on_completed_ : Callable = GDRx.basic.noop):
		this = self
		this.unreference()
		
		self.is_stopped = false
		self._handler_on_next = on_next_
		self._handler_on_error = on_error_
		self._handler_on_completed = on_completed_

func on_next(i):
	if not self.is_stopped:
		self._on_next_core(i)

func _on_next_core(i):
	self._handler_on_next.call(i)

func on_error(e):
	if not self.is_stopped:
		self.is_stopped = true
		self._on_error_core(e)

func _on_error_core(e):
	self._handler_on_error.call(e)

func on_completed():
	if not self.is_stopped:
		self.is_stopped = true
		self._on_completed_core()

func _on_completed_core():
	self._handler_on_completed.call()

func dispose():
	this.is_stopped = true

func fail(e):
	if not self.is_stopped:
		self.is_stopped = true
		self._on_error_core(e)
		return true
	return false

func throw(error : ThrowableBase):
	print_stack()
	GDRx.raise(error)

func to_notifier() -> Callable:
	return func(notifier : Notification): 
		return notifier.accept(self)

func as_observer() -> ObserverBase:
	return Observer.new(self.on_next, self.on_error, self.on_completed)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()
