extends Subject
class_name AsyncSubject

var _value
var _has_value : bool

func _init():
	super._init()
	
	self._value = null
	self._has_value = false

func _subscribe_core(
	__super : Callable,
	observer : ObserverBase,
	scheduler : SchedulerBase = null,
) -> DisposableBase:
	self._lock.lock()
	if check_disposed() != false: self._lock.unlock() ; return
	if not _OBV._is_stopped:
		self._observers.append(observer)
		return InnerSubscription.new(self, observer)
	
	var ex = self._exception
	var has_value = self._has_value
	var value = self._value
	self._lock.unlock()
	
	if ex != null:
		observer.on_error(ex)
	elif has_value:
		observer.on_next(value)
		observer.on_completed()
	else:
		observer.on_completed()
	
	return Disposable.new()

func _on_next_core(__super : Callable, i):
	self._lock.lock()
	self._value = i
	self._has_value = true
	self._lock.unlock()

func _on_completed_core(__super : Callable):
	self._lock.lock()
	var observers = self._observers.duplicate()
	self._observers.clear()
	var value = self._value
	var has_value = self._has_value
	self._lock.unlock()
	
	if has_value:
		for obs in observers:
			obs.on_next(value)
			obs.on_completed()
	else:
		for obs in observers:
			obs.on_completed()

func dispose(__super : Callable):
	self._lock.lock()
	self._value = null
	__super.call()
	self._lock.unlock()
