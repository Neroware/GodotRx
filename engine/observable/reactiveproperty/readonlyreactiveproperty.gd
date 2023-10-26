extends ReadOnlyReactivePropertyBase
class_name ReadOnlyReactiveProperty

## An observable property with read-only access.
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

func _init(
	source : ObservableBase,
	initial_value_,
	distinct_until_changed_ : bool = true,
	raise_latest_value_on_subscribe_ : bool = true
):
	var wself : WeakRef = weakref(self)
	
	self._observers = []
	self._rwlock = ReadWriteLock.new()
	self.is_disposed = false
	
	self._source_subscription = source.subscribe(
		func(i): wself.get_ref()._on_next(i),
		func(e): wself.get_ref()._on_error(e),
		func(): wself.get_ref()._on_completed()
	)
	self._latest_value = initial_value_
	self._distinct_until_changed = distinct_until_changed_
	self._raise_latest_value_on_subscribe = raise_latest_value_on_subscribe_
	
	@warning_ignore("shadowed_variable")
	var subscribe = func(
		observer : ObserverBase,
		_scheduler : SchedulerBase = null
	) -> DisposableBase:
		var prop : ReadOnlyReactiveProperty = wself.get_ref()
		
		if not prop or prop.is_disposed:
			observer.on_completed()
			return Disposable.new()
		
		if true:
			var __ = ReadWriteLockGuard.new(prop._rwlock, false)
			prop._observers.append(observer)
		
		if prop._raise_latest_value_on_subscribe:
			observer.on_next(prop._latest_value)
		
		var dispose_ = func():
			var _prop = wself.get_ref()
			if not _prop:
				return
			if true:
				var __ = ReadWriteLockGuard.new(_prop._rwlock, false)
				_prop._observers.erase(observer)
		
		return Disposable.new(dispose_)
	
	super._init(subscribe)

func _get_value():
	return self._latest_value

func dispose():
	if this.is_disposed:
		return
	
	this.is_disposed = true
	
	var observers_ : Array[ObserverBase]
	if true:
		var __ = ReadWriteLockGuard.new(this._rwlock, true)
		observers_ = this._observers.duplicate()
	for obs in observers_:
		obs.on_completed()
	
	if true:
		var __ = ReadWriteLockGuard.new(this._rwlock, false)
		this._observers.clear()
	
	this._source_subscription.dispose()

func _on_next(value):
	if self._distinct_until_changed and self._latest_value == value:
		return
	
	self._latest_value = value
	var observers_ : Array[ObserverBase]
	if true:
		var __ = ReadWriteLockGuard.new(self._rwlock, true)
		observers_ = self._observers.duplicate()
	for obs in observers_:
		obs.on_next(value)

func _on_error(error_):
	var observers_ : Array[ObserverBase]
	if true:
		var __ = ReadWriteLockGuard.new(self._rwlock, true)
		observers_ = self._observers.duplicate()
	for obs in observers_:
		obs.on_error(error_)

func _on_completed():
	self.dispose()

func _to_string() -> String:
	if self.is_disposed:
		return "<<Disposed ReadOnlyReactiveProperty>>"
	return str(self.Value)
