extends DisposableBase
class_name SingleAssignmentDisposable

var _is_disposed : bool
var _current : DisposableBase
var _lock : RLock

func _init():
	self._is_disposed = false
	self._current = null
	self._lock = RLock.new()

func get_disposabe() -> DisposableBase:
	return self._current

func disposable() -> DisposableBase:
	return self._current

func set_disposable(value : DisposableBase):
	if self._current != null:
		push_error("Disposable has already been assigned")
		return
	
	self._lock.lock()
	var should_dispose = self._is_disposed
	if not should_dispose:
		self._current = value
	self._lock.unlock()
	
	if self._is_disposed and value != null:
		value.dispose()

func dispose():
	var old = null
	
	self._lock.lock()
	if not self._is_disposed:
		self._is_disposed = true
		old = self._current
		self._current = null
	self._lock.unlock()
	
	if old != null:
		old.dispose()
