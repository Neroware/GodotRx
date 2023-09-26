extends Notification
class_name OnErrorNotification

## Represents an OnError notification to an observer.

var err

func _init(err_):
	super._init()
	self.err = err_
	self.kind = "E"

func _accept(
	_on_next : Callable,
	on_error : Callable = GDRx.basic.noop,
	_on_completed : Callable = GDRx.basic.noop):
		return on_error.call(self.err)

func _accept_observer(observer : ObserverBase):
	return observer.on_error(self.err)

func _to_string():
	return "OnError(" + str(self.err) + ")"
