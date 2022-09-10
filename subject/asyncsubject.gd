extends Subject
class_name AsyncSubject

## Represents the result of an asynchronous operation. 
##
## The last value before the close notification, or the error received through
## [i]on_error[/i], is sent to all subscribed observers.

var _value
var _has_value : bool

## Creates a subject that can only receive one value and that value is
## cached for all future observations.
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
		var ret_ = InnerSubscription.new(self, observer)
		self._lock.unlock()
		return ret_
	
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

## Remember the value. Upon completion, the most recently received value
##        will be passed on to all subscribed observers.
## [br][br]
##        [b]Args:[/b]
## [br]
##            [code]value[/code] The value to remember until completion
func _on_next_core(__super : Callable, i):
	self._lock.lock()
	self._value = i
	self._has_value = true
	self._lock.unlock()

## Notifies all subscribed observers of the end of the sequence. The
## most recently received value, if any, will now be passed on to all
## subscribed observers.
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

## Unsubscribe all observers and release resources.
func dispose(__super : Callable):
	self._lock.lock()
	self._value = null
	__super.call()
	self._lock.unlock()
