extends Observable
class_name ReadOnlyReactiveProperty

var _prop : ReactiveProperty


func _init(prop : ReactiveProperty):
	self._prop = prop
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		return _prop.subscribe(observer)
	
	super(subscribe)

func Get():
	return self._prop.Get()

func with_getter(getter : Callable = func(v): return v):
	self._prop.with_getter(getter)
	return self

func with_setter(setter : Callable = func(old_v, new_v): return new_v):
	self._prop.with_setter(setter)
	return self

func with_condition(cond = func(v_old, v_new): return v_old != v_new):
	self._prop.with_condition(cond)
	return self

func dispose():
	self._prop.dispose()
