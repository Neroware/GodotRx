extends ObserverBase
class_name AutoDetachObserver

var _on_next : Callable
var _on_error : Callable
var _on_completed : Callable

var _is_stopped : bool
var _subscription : SingleAssignmentDisposable

func _init(
	on_next : Callable = func(i): return,
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return):
		self._on_next = on_next
		self._on_error = on_error
		self._on_completed = on_completed
		
		self._subscription = SingleAssignmentDisposable.new()
		self._is_stopped = false

func on_next(i):
	if self._is_stopped:
		return
	self._on_next.call(i)

func on_error(e):
	if self._is_stopped:
		return
	self._is_stopped = true
	
	self._on_error.call(e)
	self.dispose()

func on_completed():
	if self._is_stopped:
		return
	self._is_stopped = true
	
	self._on_completed.call()
	self.dispose()

func set_disposable(value : DisposableBase):
	self._subscription.set_disposable(value)

func subscription() -> DisposableBase:
	return self._subscription.get_disposabe()

func dispose():
	self._is_stopped = true
	self._subscription.dispose()

func fail(err) -> bool:
	if self._is_stopped:
		return false
	
	self._is_stopped = true
	self._on_error.call(err)
	return true
