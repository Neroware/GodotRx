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
	self.value = value

func _subscribe_core(
	__super : Callable,
	observer : ObserverBase,
	scheduler : SchedulerBase = null,
) -> DisposableBase:
	self.lock.lock()
	if not check_disposed(): self.lock.unlock() ; return Disposable.new()
	if not _OBV.is_stopped:
		self.observers.append(observer)
		observer.on_next(self.value)
		var sub_ = InnerSubscription.new(self, observer)
		self.lock.unlock()
		return sub_
	var ex = self.exception
	self.lock.unlock()
	
	if ex != null:
		observer.on_error(ex)
	else:
		observer.on_completed()
	
	return Disposable.new()

## Notifies all subscribed observers with the value.
func _on_next_core(__super : Callable, i):
	self.lock.lock()
	var observers = self.observers.duplicate()
	self.value = i
	self.lock.unlock()
	
	for observer in observers:
		observer.on_next(i)

## Release all resources.
##
## Releases all resources used by the current instance of the
## [BehaviorSubject] class and unsubscribe all observers.
func dispose(__super : Callable):
	self.lock.lock()
	self.value = null
	__super.call()
	self.lock.unlock()
