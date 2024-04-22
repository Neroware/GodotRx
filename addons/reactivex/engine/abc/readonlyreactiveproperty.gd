extends Observable
class_name ReadOnlyReactivePropertyBase

## Wrapped value
var Value:
	set(value): self._set_value(value)
	get: return self._get_value()

var this

func _init(subscribe : Callable):
	this = self
	this.unreference()
	
	super._init(subscribe)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()

func _set_value(__):
	GDRx.raise_message("Tried to write to a ReadOnlyReactiveProperty")

func _get_value():
	NotImplementedError.raise()
	return null

func eq(other) -> bool:
	if other is ReadOnlyReactivePropertyBase:
		return GDRx.eq(Value, other.Value)
	return GDRx.eq(Value, other)

func dispose():
	NotImplementedError.raise()
