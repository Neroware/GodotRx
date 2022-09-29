extends Notification
class_name OnCompletedNotification

## Represents an OnCompleted notification to an observer.

func _init():
	super._init()
	self.kind = "C"

func _accept(
	_on_next : Callable,
	_on_error : Callable = func(e): return,
	on_completed : Callable = func(): return):
		return on_completed.call()

func _accept_observer(observer : ObserverBase):
	return observer.on_completed()

func _to_string():
	return "OnCompleted()"
