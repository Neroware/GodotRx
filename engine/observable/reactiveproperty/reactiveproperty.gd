extends Observable
class_name ReactiveProperty

## An observable property.
##
## Wraps a value and emits an item whenever it is changed under a specified 
## condition. The item is of type [Tuple] containing the old and new value.

signal _on_changed(v_old, v_new)
signal _on_dispose()

var _cond : Callable
var _getter : Callable
var _setter : Callable

var _initialized : bool
var _disposed : bool

## The wrapped value
var Value:
	get:
		self._lock.lock()
		if _disposed:
			push_error("Property has been disposed!")
			self._lock.unlock()
			return null
		var _ret = _getter.call(Value)
		self._lock.unlock()
		return _ret
	
	set(value):
		if not _initialized:
			Value = value
			_initialized = true
			return
		
		self._lock.lock()
		var tmp = Value
		if _disposed:
			push_error("Property has been disposed!")
			self._lock.unlock()
			return
		value = _setter.call(tmp, value)
		Value = value
		self._lock.unlock()
		_on_changed.emit(tmp, value)

## Returns the wrapped value
func getv():
	return Value

## Sets the wrapped value
func setv(value):
	Value = value

## Sets a getter function which is called when the value is read before the
## item is emitted on the stream.
func with_getter(getter : Callable = func(v): return v) -> ReactiveProperty:
	self._lock.lock()
	self._getter = getter
	self._lock.unlock()
	return self

## Sets a setter function which is called when the value is updated before the
## item is emitted on the stream.
func with_setter(setter : Callable = func(old_v, new_v): return new_v) -> ReactiveProperty:
	self._lock.lock()
	self._setter = setter
	self._lock.unlock()
	return self

## Sets the condition whether an item is emitted when the value is updated.
func with_condition(cond = func(v_old, v_new): return v_old != v_new) -> ReactiveProperty:
	self._lock.lock()
	self._cond = cond
	self._lock.unlock()
	return self

## Disposes the reactive property. Reading the value afterwards will cause an error.
func dispose():
	self._lock.lock()
	if not self._disposed:
		self._disposed = true
		_on_dispose.emit()
	self._lock.unlock()

func _init(value, cond = func(v_old, v_new): return v_old != v_new):
	_initialized = false
	_cond = cond
	_getter = func(v): return v
	_setter = func(old_v, new_v): return new_v
	
	Value = value
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		
		var on_dispose = func(__):
			observer.on_completed()
		
		var sub = GDRx.gd.from_godot_signal(self._on_changed).subscribe(observer)
		var d = GDRx.gd.from_godot_signal(self._on_dispose).subscribe(on_dispose)
		
		return CompositeDisposable.new([sub, d])
	
	super._init(subscribe)

## Creates a reactive property that emits an item when the updated value differs.
static func ChangedValue(value = null):
	return ReactiveProperty.new(value, func(o, n): return o != n)

## Creates a reactive property that emits an item when the updated value is in 
## a collection.
static func ValueInCollection(value = null, collection = []):
	return ReactiveProperty.new(value, func(__, n): return n in collection)

## Creates a reactive property that emits an item when the updated value is not 
## in a collection.
static func NotValueInCollection(value = null, collection = []):
	return ReactiveProperty.new(value, func(__, n): return not n in collection)

## Creates a reactive property that emits an item when the updated value is 
## greater than a specified value.
static func GreaterThan(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n > what)

## Creates a reactive property that emits an item when the updated value is 
## greater than or equals a specified value.
static func GreaterEquals(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n >= what)

## Creates a reactive property that emits an item when the updated value is 
## less than a specified value.
static func LessThan(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n < what)

## Creates a reactive property that emits an item when the updated value is 
## less than or equals a specified value.
static func LessEquals(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n <= what)

## Creates a reactive property that emits an item when the updated value is 
## less than or equals a specified value.
static func NotEquals(value = null, what = 0):
	return ReactiveProperty.new(value, func(__, n): return n != what)

## Creates a reactive property that emits an item when the updated value is 
## within a certain range.
static func InsideRange(value = 0, r_min = -1, r_max = 1):
	return ReactiveProperty.new(value, func(__, n): 
		return n >= r_min and n <= r_max)

## Creates a reactive property that emits an item when the updated value is 
## outside a certain range.
static func OutsideRange(value = 0, r_min = -1, r_max = 1):
	return ReactiveProperty.new(value, func(__, n): 
		return not (n >= r_min and n <= r_max))

## Creates a reactive property that emits an item when the given condition
## applies.
static func With(value = null, cond = func(o, n): return o != n):
	return ReactiveProperty.new(value, cond)

func _to_string():
	return str(Value)
