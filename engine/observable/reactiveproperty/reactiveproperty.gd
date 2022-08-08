extends Observable
class_name ReactiveProperty

signal _on_changed(v_old, v_new)
signal _on_dispose()

var _Value:
	get:
		return _Value
	set(value):
		var tmp = _Value
		_Value = value
		emit_signal("_on_changed", tmp, _Value)

var _cond : Callable
var _getter : Callable
var _setter : Callable
var _disposed : bool

func getv():
	_lock.lock()
	if _disposed:
		push_error("Property has been disposed!")
		_lock.unlock()
		return null
	var _ret = _getter.call(_Value)
	_lock.unlock()
	return _ret

func setv(value):
	_lock.lock()
	if _disposed:
		push_error("Property has been disposed!")
		_lock.unlock()
		return null
	value = _setter.call(_Value, value)
	_Value = value
	_lock.unlock()

func with_getter(getter : Callable = func(v): return v):
	_lock.lock()
	self._getter = getter
	_lock.unlock()
	return self

func with_setter(setter : Callable = func(old_v, new_v): return new_v):
	_lock.lock()
	self._setter = setter
	_lock.unlock()
	return self

func with_condition(cond = func(v_old, v_new): return v_old != v_new):
	_lock.lock()
	self._cond = cond
	_lock.unlock()
	return self

func dispose():
	self._lock.lock()
	if not self._disposed:
		self._disposed = true
		_on_dispose.emit()
	self._lock.unlock()

func _init(value, cond = func(v_old, v_new): return v_old != v_new):
	_Value = value
	_cond = cond
	_getter = func(v): return v
	_setter = func(old_v, new_v): return new_v
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		
		var on_dispose = func(__):
			observer.on_completed()
		
		var sub = GDRx.gd.from_godot_signal(self, "_on_changed", 2).subscribe(observer)
		var d = GDRx.gd.from_godot_signal(self, "_on_dispose", 0).subscribe(on_dispose)
		
		return CompositeDisposable.new([sub, d])
	
	super._init(subscribe)

static func ChangedValue(value = null):
	return ReactiveProperty.new(value, func(o, n): return o != n)

static func ValueInCollection(value = null, collection = []):
	return ReactiveProperty.new(value, func(__, n): return n in collection)

static func NotValueInCollection(value = null, collection = []):
	return ReactiveProperty.new(value, func(__, n): return not n in collection)

static func GreaterThan(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n > what)

static func GreaterEquals(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n >= what)

static func LessThan(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n < what)

static func LessEquals(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n <= what)

static func NotEquals(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n != what)

static func InsideRange(value = 0, r_min = -1, r_max = 1):
	return ReactiveProperty.new(value, func(__, n): 
		return n >= r_min and n <= r_max)

static func OutsideRange(value = 0, r_min = -1, r_max = 1):
	return ReactiveProperty.new(value, func(__, n): 
		return not (n >= r_min and n <= r_max))

static func With(value = null, cond = func(o, n): return o != n):
	return ReactiveProperty.new(value, cond)
