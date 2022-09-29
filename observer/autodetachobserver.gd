extends ObserverBase
class_name AutoDetachObserver

var _on_next : Callable
var _on_error : Callable
var _on_completed : Callable

var _subscription : SingleAssignmentDisposable

var is_stopped : bool

func _init(
	on_next_ : Callable = func(i): return,
	on_error_ : Callable = func(e): return,
	on_completed_ : Callable = func(): return):
		self._on_next = on_next_
		self._on_error = on_error_
		self._on_completed = on_completed_
		
		self._subscription = SingleAssignmentDisposable.new()
		self.is_stopped = false

func on_next(i):
	if self.is_stopped:
		return
	self._on_next.call(i)

func on_error(e):
	if self.is_stopped:
		return
	self.is_stopped = true
	
	GDRx.try(func():
		self._on_error.call(e)
	).end_try_catch()
	self.dispose()

func on_completed():
	if self.is_stopped:
		return
	self.is_stopped = true
	
	GDRx.try(func():
		self._on_completed.call()
	).end_try_catch()
	self.dispose()

func set_disposable(value : DisposableBase):
	self._subscription.disposable = value

var subscription: set = set_disposable

func dispose():
	self.is_stopped = true
	self._subscription.dispose()

func fail(err) -> bool:
	if self.is_stopped:
		return false
	
	self.is_stopped = true
	self._on_error.call(err)
	return true
