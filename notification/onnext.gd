extends Notification
class_name OnNextNotification

## Represents an OnNext notification to an observer.

func _init(value_):
	super._init()
	self.value = value_
	self.has_value = true
	self.kind = "N"

func _accept(
	on_next : Callable,
	_on_error : Callable = GDRx.basic.noop,
	_on_completed : Callable = GDRx.basic.noop):
		return on_next.call(self.value)

func _accept_observer(observer : ObserverBase):
	return observer.on_next(self.value)

func _to_string():
	return "OnNext(" + str(self.value) + ")"
