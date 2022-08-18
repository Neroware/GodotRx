extends Observable
class_name ReadOnlyReactiveProperty

var _prop : ReactiveProperty

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

func getv():
	return self._prop.getv()

func with_getter(getter : Callable = func(v): return v) -> ReadOnlyReactiveProperty:
	self._prop.with_getter(getter)
	return self

func with_setter(setter : Callable = func(old_v, new_v): return new_v) -> ReadOnlyReactiveProperty:
	self._prop.with_setter(setter)
	return self

func with_condition(cond = func(v_old, v_new): return v_old != v_new) -> ReadOnlyReactiveProperty:
	self._prop.with_condition(cond)
	return self

func dispose():
	self._prop.dispose()
