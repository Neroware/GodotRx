extends Subject
class_name BehaviorSubject

var _value

func _init(value):
	super._init()
	self._value = value

func _subscribe_core(
	__super : Callable,
	observer : ObserverBase,
	scheduler : SchedulerBase = null,
) -> DisposableBase:
	self._lock.lock()
	if check_disposed() != false: self._lock.unlock() ; return Disposable.new()
	if not _OBV._is_stopped:
		self._observers.append(observer)
		observer.on_next(self._value)
		var sub_ = InnerSubscription.new(self, observer)
		self._lock.unlock()
		return sub_
	var ex = self._exception
	self._lock.unlock()
	
	if ex != null:
		observer.on_error(ex)
	else:
		observer.on_completed()
	
	return Disposable.new()

func _on_next_core(__super : Callable, i):
	self._lock.lock()
	var observers = self._observers.duplicate()
	self._value = i
	self._lock.unlock()
	
	for observer in observers:
		observer.on_next(i)

func dispose(__super : Callable):
	self._lock.lock()
	self._value = null
	__super.call()
	self._lock.unlock()
