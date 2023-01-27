extends Observable
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

## Wrapped value
var Value:
	get: return self._latest_value
	set(__):
		GDRx.raise_message("Tried to write to a ReadOnlyReactiveProperty")

func _init(
	source : ObservableBase,
	initial_value_,
	distinct_until_changed_ : bool = true,
	raise_latest_value_on_subscribe_ : bool = true
):
	self._observers = []
	self._rwlock = ReadWriteLock.new()
	
	self._source_subscription = source.subscribe(self)
	self._latest_value = initial_value_
	self._distinct_until_changed = distinct_until_changed_
	self._raise_latest_value_on_subscribe = raise_latest_value_on_subscribe_
	
	@warning_ignore("shadowed_variable")
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		
		if self.is_disposed:
			observer.on_completed()
			return Disposable.new()
		
		self._rwlock.w_lock()
		self._observers.append(observer)
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
	
	self._source_subscription.dispose()

func on_next(value):
	if self._distinct_until_changed and self._latest_value == value:
		return
	
	self._latest_value = value
	var observers_ : Array[ObserverBase]
	self._rwlock.r_lock()
	observers_ = self._observers.duplicate()
	self._rwlock.r_unlock()
	for obs in observers_:
		obs.on_next(value)

func on_error(error):
	var observers_ : Array[ObserverBase]
	self._rwlock.r_lock()
	observers_ = self._observers.duplicate()
	self._rwlock.r_unlock()
	for obs in observers_:
		obs.on_error(error)

func on_completed():
	self.dispose()
