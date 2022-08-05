extends Notification
class_name OnNextNotification

func _init(value):
	super._init()
	self._value = value
	self._has_value = true
	self._kind = "N"

func _accept(
	on_next : Callable,
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return):
		return on_next.call(self._value)

func _accept_observer(observer : ObserverBase):
	return observer.on_next(self._value)

func _to_string():
	return "OnNext(" + str(self._value) + ")"
