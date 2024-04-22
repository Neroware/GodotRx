extends ReactiveDictionaryBase
class_name ReactiveDictionary

var _count : int
var _data : Dictionary
var _observers : Dictionary
var _rwlock : ReadWriteLock

var is_disposed : bool

func _get_subscription(event_class, notify_count = false) -> Callable:
	var wself : WeakRef = weakref(self)
	
	return func(observer : ObserverBase, _scheduler : SchedulerBase = null) -> DisposableBase:
		var prop : ReactiveDictionary = wself.get_ref()
		
		if not prop or prop.is_disposed:
			observer.on_completed()
			return Disposable.new()
		
		if notify_count:
			observer.on_next(prop.Count)
		
		if true:
			var __ = ReadWriteLockGuard.new(prop._rwlock, false)
			if not (event_class in prop._observers):
				prop._observers[event_class] = []
			prop._observers[event_class].push_back(observer)
		
		var dispose_ = func():
			var _prop = wself.get_ref()
			if not _prop:
				return
			var __ = ReadWriteLockGuard.new(prop._rwlock, false)
			prop._observers[event_class].erase(observer)
		
		return Disposable.new(dispose_)

func _notify_all(event_class, event):
	var observers_ : Array
	if true:
		var __ = ReadWriteLockGuard.new(self._rwlock, true)
		if event_class in self._observers:
			observers_ = self._observers[event_class].duplicate()
	for observer in observers_:
		observer.on_next(event)

func _disconnect_all(event_class):
	var observers_ : Array
	if true:
		var __ = ReadWriteLockGuard.new(this._rwlock, true)
		if event_class in this._observers:
			observers_ = this._observers[event_class].duplicate()
	for observer in observers_:
		observer.on_completed()

func _init(dict : Dictionary = {}):
	super._init()
	
	self._count = 0
	self._data = dict.duplicate()
	self._observers = {}
	self._rwlock = ReadWriteLock.new()
	self.is_disposed = false
	
	self._observe_add_key = Observable.new(self._get_subscription(DictionaryAddKeyEvent))
	self._observe_remove_key = Observable.new(self._get_subscription(DictionaryRemoveKeyEvent))
	self._observer_update_value = Observable.new(self._get_subscription(DictionaryUpdateValueEvent))

func ObserveCountChanged(notify_current_count : bool = false) -> Observable:
	return Observable.new(self._get_subscription("CountChanged", notify_current_count))

func clear():
	var keys = self.keys()
	for key in keys:
		self.erase(key)

func erase(key) -> bool:
	if self.is_disposed:
		DisposedError.raise()
		return false
	if self._data.has(key):
		var value = self._data[key]
		self._data.erase(key)
		self._count -= 1
		self._notify_all("CountChanged", self._count)
		self._notify_all(DictionaryRemoveKeyEvent, DictionaryRemoveKeyEvent.new(key, value))
		return true
	return false

func set_pair(key, value):
	if self.is_disposed:
		DisposedError.raise()
		return null
	if not self._data.has(key):
		self._count += 1
		self._data[key] = value
		self._notify_all("CountChanged", self._count)
		self._notify_all(DictionaryAddKeyEvent, DictionaryAddKeyEvent.new(key, value))
	else:
		self._data[key] = value
		self._notify_all(DictionaryUpdateValueEvent, DictionaryUpdateValueEvent.new(key, value))

func to_dict() -> Dictionary:
	if self.is_disposed:
		DisposedError.raise()
		return {}
	return self._data.duplicate()

func find_key(value) -> Variant:
	if self.is_disposed:
		DisposedError.raise()
		return null
	return self._data.find_key(value)

func get_value(key, default = null) -> Variant:
	if self.is_disposed:
		DisposedError.raise()
		return null
	return self._data.get(key, default)

func has_key(key) -> bool:
	if self.is_disposed:
		DisposedError.raise()
		return false
	return self._data.has(key)

func has_all(keys : Array) -> bool:
	if self.is_disposed:
		DisposedError.raise()
		return false
	return self._data.has_all(keys)

func hash() -> int:
	if self.is_disposed:
		DisposedError.raise()
		return 0
	return self._data.hash()

func is_empty() -> bool:
	if self.is_disposed:
		DisposedError.raise()
		return false
	return self._data.is_empty()

func keys() -> Array:
	if self.is_disposed:
		DisposedError.raise()
		return []
	return self._data.keys()

func size() -> int: 
	if self.is_disposed:
		DisposedError.raise()
		return -1
	return self._count

func values() -> Array:
	if self.is_disposed:
		DisposedError.raise()
		return []
	return self._data.values()

func dispose():
	if this.is_disposed:
		return
	this.is_disposed = true
	
	this._disconnect_all(DictionaryAddKeyEvent)
	this._disconnect_all(DictionaryRemoveKeyEvent)
	this._disconnect_all(DictionaryUpdateValueEvent)
	this._disconnect_all("CountChanged")
	
	this._data = {}
	this._count = -1
	this._observers = {}

func to_readonly() -> ReadOnlyReactiveDictionary:
	return ReadOnlyReactiveDictionary.new(self)

func _to_string() -> String:
	if self.is_disposed:
		return "<<Disposed ReactiveDictionary>>"
	return str(self._data)
