extends Notification
class_name OnErrorNotification

var _err

func _init(err):
	super._init()
	self._err = err
	self._kind = "E"

func _accept(
	on_next : Callable,
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return):
		return on_error.call(self._err)

func _accept_observer(observer : ObserverBase):
	return observer.on_error(self._err)

func _to_string():
	return "OnError(" + str(self.err) + ")"
