extends Notification
class_name OnErrorNotification

## Represents an OnError notification to an observer.

var err

func _init(err):
	super._init()
	self.err = err
	self.kind = "E"

func _accept(
	on_next : Callable,
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return):
		return on_error.call(self.err)

func _accept_observer(observer : ObserverBase):
	return observer.on_error(self.err)

func _to_string():
	return "OnError(" + str(self.err) + ")"
