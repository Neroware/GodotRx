extends Subject
class_name AsyncSubject

## Represents the result of an asynchronous operation. 
##
## The last value before the close notification, or the error received through
## [i]on_error[/i], is sent to all subscribed observers.

var value
var has_value : bool

## Creates a subject that can only receive one value and that value is
## cached for all future observations.
func _init():
	super._init()
	
	self.value = null
	self.has_value = false

func _subscribe_core(
	__super : Callable,
	observer : ObserverBase,
	scheduler : SchedulerBase = null,
) -> DisposableBase:
	self.lock.lock()
	if not check_disposed(): self.lock.unlock() ; return
	if not _OBV.is_stopped:
		self.observers.append(observer)
		var ret_ = InnerSubscription.new(self, observer)
		self.lock.unlock()
		return ret_
	
	var ex = self.exception
	var has_value = self.has_value
	var value = self.value
	self.lock.unlock()
	
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
	self.lock.lock()
	self.value = i
	self.has_value = true
	self.lock.unlock()

## Notifies all subscribed observers of the end of the sequence. The
## most recently received value, if any, will now be passed on to all
## subscribed observers.
func _on_completed_core(__super : Callable):
	self.lock.lock()
	var observers = self.observers.duplicate()
	self.observers.clear()
	var value = self.value
	var has_value = self.has_value
	self.lock.unlock()
	
	if has_value:
		for obs in observers:
			obs.on_next(value)
			obs.on_completed()
	else:
		for obs in observers:
			obs.on_completed()

## Unsubscribe all observers and release resources.
func dispose(__super : Callable):
	self.lock.lock()
	self.value = null
	__super.call()
	self.lock.unlock()
