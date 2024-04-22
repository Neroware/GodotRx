extends Subject
class_name BehaviorSubject

## Represents a value that changes over time.
##
## Observers can subscribe to the subject to receive the last (or initial) value and
## all subsequent notifications.

var value

## Initializes a new instance of the BehaviorSubject class which
## creates a subject that caches its last value and starts with the
## specified value.
## [br]
## [b]Args:[/b]
## [br]
##    [code]value[/code] Initial value sent to observers when no other value has been
##    received by the subject yet.
func _init(value_):
	super._init()
	self.value = value_

func _subscribe_core(
	observer : ObserverBase,
	_scheduler : SchedulerBase = null,
) -> DisposableBase:
	var err
	if true:
		var __ = LockGuard.new(self.lock)
		if not check_disposed(): return Disposable.new()
		if not self.is_stopped:
			self.observers.append(observer)
			observer.on_next(self.value)
			return InnerSubscription.new(self, observer)
		err = self.error_value
	
	if err != null:
		observer.on_error(err)
	else:
		observer.on_completed()
	
	return Disposable.new()

## Notifies all subscribed observers with the value.
func _on_next_core(i):
	var observers_
	if true:
		var __ = LockGuard.new(self.lock)
		observers_ = self.observers.duplicate()
		self.value = i
	
	for observer in observers_:
		observer.on_next(i)

## Release all resources.
## 
## Releases all resources used by the current instance of the
## [BehaviorSubject] class and unsubscribe all observers.
func dispose():
	if true:
		var __ = LockGuard.new(self.lock)
		self.value = null
		super.dispose()
