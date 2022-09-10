extends Subject
class_name BehaviorSubject

## Represents a value that changes over time.
##
## Observers can subscribe to the subject to receive the last (or initial) value and
## all subsequent notifications.

var _value

## Initializes a new instance of the BehaviorSubject class which
##        creates a subject that caches its last value and starts with the
##        specified value.
## [br]
##        [b]Args:[/b]
## [br]
##            [code]value[/code] Initial value sent to observers when no other value has been
##                received by the subject yet.
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

## Notifies all subscribed observers with the value.
func _on_next_core(__super : Callable, i):
	self._lock.lock()
	var observers = self._observers.duplicate()
	self._value = i
	self._lock.unlock()
	
	for observer in observers:
		observer.on_next(i)

## Release all resources.
##
## Releases all resources used by the current instance of the
## [BehaviorSubject] class and unsubscribe all observers.
func dispose(__super : Callable):
	self._lock.lock()
	self._value = null
	__super.call()
	self._lock.unlock()
