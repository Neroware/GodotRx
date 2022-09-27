extends Notification
class_name OnNextNotification

## Represents an OnNext notification to an observer.

func _init(value):
	super._init()
	self.value = value
	self.has_value = true
	self.kind = "N"

func _accept(
	on_next : Callable,
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return):
		return on_next.call(self.value)

func _accept_observer(observer : ObserverBase):
	return observer.on_next(self.value)

func _to_string():
	return "OnNext(" + str(self.value) + ")"
