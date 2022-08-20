extends Observable
class_name ReadOnlyReactiveProperty

## An observable property with read-only access.
##
## Wraps a value and emits an item whenever it is changed under a specified 
## condition. The item is of type [Tuple] containing the old and new value.

var _prop : ReactiveProperty

## The wrapped value
var Value:
	get:
		return getv()

func _init(prop : ReactiveProperty):
	self._prop = prop
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		return _prop.subscribe(observer)
	
	super(subscribe)

## Returns the wrapped value
func getv():
	return self._prop.getv()

## Sets a getter function which is called when the value is read before the
## item is emitted on the stream.
func with_getter(getter : Callable = func(v): return v) -> ReadOnlyReactiveProperty:
	self._prop.with_getter(getter)
	return self

## Sets a setter function which is called when the value is updated before the
## item is emitted on the stream.
func with_setter(setter : Callable = func(old_v, new_v): return new_v) -> ReadOnlyReactiveProperty:
	self._prop.with_setter(setter)
	return self

## Sets the condition whether an item is emitted when the value is updated.
func with_condition(cond = func(v_old, v_new): return v_old != v_new) -> ReadOnlyReactiveProperty:
	self._prop.with_condition(cond)
	return self

## Disposes the reactive property. Reading the value afterwards will cause an error.
func dispose():
	self._prop.dispose()
