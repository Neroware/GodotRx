extends Observable
class_name ReactiveProperty

## An observable property.
##
## Wraps a value and emits an item whenever it is changed.
## The emitted item is the new value of the [ReactiveProperty].

var _latest_value
var _source_subscription : DisposableBase
var _observers : Array[ObserverBase]
var _distinct_until_changed : bool
var _raise_latest_value_on_subscribe : bool

var _rwlock : ReadWriteLock

var is_disposed : bool
## Wrapped value
var Value:
	get: return self._latest_value
	
	set(value):
		if self._distinct_until_changed and self._latest_value == value:
			return
		self._latest_value = value
		
		var observers_ : Array[ObserverBase]
		self._rwlock.r_lock()
		observers_ = self._observers.duplicate()
		self._rwlock.r_unlock()
		for obs in observers_:
			obs.on_next(value)

func _to_string() -> String:
	if self.is_disposed:
		return "<<Disposed ReactiveProperty>>"
	return str(self._latest_value)

func _init(
	initial_value_,
	distinct_until_changed_ : bool = true,
	raise_latest_value_on_subscribe_ : bool = true,
	source : Observable = null
):
	self._observers = []
	self._rwlock = ReadWriteLock.new()
	
	self._latest_value = initial_value_
	self._distinct_until_changed = distinct_until_changed_
	self._raise_latest_value_on_subscribe = raise_latest_value_on_subscribe_
	
	if source != null:
		self._source_subscription = source.subscribe(func(i): Value = i)
	
	@warning_ignore(shadowed_variable)
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		if self.is_disposed:
			observer.on_completed()
			return Disposable.new()
		
		self._rwlock.w_lock()
		self._observers.push_back(observer)
		self._rwlock.w_unlock()
		
		if self._raise_latest_value_on_subscribe:
			observer.on_next(self._latest_value)
		
		var dispose_ = func():
			self._rwlock.w_lock()
			self._observers.erase(observer)
			self._rwlock.w_unlock()
		
		return Disposable.new(dispose_)
	
	super._init(subscribe)

func dispose():
	if self.is_disposed:
		return
	
	self.is_disposed = true
	
	var observers_ : Array[ObserverBase]
	self._rwlock.r_lock()
	observers_ = self._observers.duplicate()
	self._rwlock.r_unlock()
	for obs in observers_:
		obs.on_completed()
	
	self._rwlock.w_lock()
	self._observers.clear()
	self._rwlock.w_unlock()
	
	if self._source_subscription != null:
		self._source_subscription.dispose()

func to_readonly() -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(
		self, Value, self._distinct_until_changed, 
		self._raise_latest_value_on_subscribe
	)

static func FromGetSet(
	getter : Callable,
	setter : Callable,
	distinct_until_changed_ : bool = true,
	raise_latest_value_on_subscribe_ : bool = true
) -> ReactiveProperty:
	var prop = ReactiveProperty.new(
		getter.call(),
		distinct_until_changed_,
		raise_latest_value_on_subscribe_
	)
	
	prop.subscribe(func(x): setter.call(x))
	return prop

static func FromMember(
	target,
	member_name : StringName,
	convert_cb = func(x): return x,
	convert_back_cb = func(x): return x,
	distinct_until_changed_ : bool = true,
	raise_latest_value_on_subscribe_ : bool = true
) -> ReactiveProperty:
	
	var getter = func():
		return target.get(member_name)
	var setter = func(v):
		target.set(member_name, v)
	
	return FromGetSet(
		func(): return convert_cb.call(getter.call()),
		func(x): setter.call(convert_back_cb.call(x)),
		distinct_until_changed_,
		raise_latest_value_on_subscribe_
	)

static func Derived(p : ReadOnlyReactiveProperty, fn : Callable) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(
		p.map(fn),
		fn.call(p.Value)
	)

static func Computed1(p : ReadOnlyReactiveProperty, fn : Callable) -> ReadOnlyReactiveProperty:
	return Derived(p, fn)

static func Computed2(
	p1 : ReadOnlyReactiveProperty,
	p2 : ReadOnlyReactiveProperty,
	fn : Callable
) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(
		p1.combine_latest([p2 as Observable]).map(func(tup : Tuple): return fn.call(tup.at(0), tup.at(1))),
		fn.call(p1.Value, p2.Value)
	)

static func Computed3(
	p1 : ReadOnlyReactiveProperty,
	p2 : ReadOnlyReactiveProperty,
	p3 : ReadOnlyReactiveProperty,
	fn : Callable
) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(
		p1.combine_latest([p2 as Observable, p3 as Observable]).map(func(tup : Tuple): return fn.call(tup.at(0), tup.at(1), tup.at(2))),
		fn.call(p1.Value, p2.Value, p3.Value)
	)

static func Computed4(
	p1 : ReadOnlyReactiveProperty,
	p2 : ReadOnlyReactiveProperty,
	p3 : ReadOnlyReactiveProperty,
	p4 : ReadOnlyReactiveProperty,
	fn : Callable
) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(
		p1.combine_latest([p2 as Observable, p3 as Observable, p4 as Observable]).map(func(tup : Tuple): return fn.call(tup.at(0), tup.at(1), tup.at(2), tup.at(3))),
		fn.call(p1.Value, p2.Value, p3.Value, p4.Value)
	)

static func Computed5(
	p1 : ReadOnlyReactiveProperty,
	p2 : ReadOnlyReactiveProperty,
	p3 : ReadOnlyReactiveProperty,
	p4 : ReadOnlyReactiveProperty,
	p5 : ReadOnlyReactiveProperty,
	fn : Callable
) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(
		p1.combine_latest([p2 as Observable, p3 as Observable, p4 as Observable, p5 as Observable]).map(func(tup : Tuple): return fn.call(tup.at(0), tup.at(1), tup.at(2), tup.at(3), tup.at(4))),
		fn.call(p1.Value, p2.Value, p3.Value, p4.Value, p5.Value)
	)

static func Computed6(
	p1 : ReadOnlyReactiveProperty,
	p2 : ReadOnlyReactiveProperty,
	p3 : ReadOnlyReactiveProperty,
	p4 : ReadOnlyReactiveProperty,
	p5 : ReadOnlyReactiveProperty,
	p6 : ReadOnlyReactiveProperty,
	fn : Callable
) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(
		p1.combine_latest([p2 as Observable, p3 as Observable, p4 as Observable, p5 as Observable, p6 as Observable]).map(func(tup : Tuple): return fn.call(tup.at(0), tup.at(1), tup.at(2), tup.at(3), tup.at(4), tup.at(5))),
		fn.call(p1.Value, p2.Value, p3.Value, p4.Value, p5.Value, p6.Value)
	)

static func Computed7(
	p1 : ReadOnlyReactiveProperty,
	p2 : ReadOnlyReactiveProperty,
	p3 : ReadOnlyReactiveProperty,
	p4 : ReadOnlyReactiveProperty,
	p5 : ReadOnlyReactiveProperty,
	p6 : ReadOnlyReactiveProperty,
	p7 : ReadOnlyReactiveProperty,
	fn : Callable
) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(
		p1.combine_latest([p2 as Observable, p3 as Observable, p4 as Observable, p5 as Observable, p6 as Observable, p7 as Observable]).map(func(tup : Tuple): return fn.call(tup.at(0), tup.at(1), tup.at(2), tup.at(3), tup.at(4), tup.at(5), tup.at(6))),
		fn.call(p1.Value, p2.Value, p3.Value, p4.Value, p5.Value, p6.Value, p7.Value)
	)

static func Computed8(
	p1 : ReadOnlyReactiveProperty,
	p2 : ReadOnlyReactiveProperty,
	p3 : ReadOnlyReactiveProperty,
	p4 : ReadOnlyReactiveProperty,
	p5 : ReadOnlyReactiveProperty,
	p6 : ReadOnlyReactiveProperty,
	p7 : ReadOnlyReactiveProperty,
	p8 : ReadOnlyReactiveProperty,
	fn : Callable
) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(
		p1.combine_latest([p2 as Observable, p3 as Observable, p4 as Observable, p5 as Observable, p6 as Observable, p7 as Observable, p8 as Observable]).map(func(tup : Tuple): return fn.call(tup.at(0), tup.at(1), tup.at(2), tup.at(3), tup.at(4), tup.at(5), tup.at(6), tup.at(7))),
		fn.call(p1.Value, p2.Value, p3.Value, p4.Value, p5.Value, p6.Value, p7.Value, p8.Value)
	)
