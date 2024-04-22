extends ReadOnlyReactiveDictionaryBase
class_name ReadOnlyReactiveDictionary

var _dict : ReactiveDictionaryBase
var _observers : Array[ObserverBase]

var is_disposed : bool

class _Observable extends Observable:
	func _init(source : Observable, observers : Array[ObserverBase]):
		var subscribe_ = func(observer, scheduler = null):
			if not observer in observers:
				observers.push_back(observer)
			return source.subscribe1(observer, scheduler)
		super._init(subscribe_)

func _init(dict : ReactiveDictionary):
	super._init()
	
	self.is_disposed = false
	
	self._dict = dict
	self._observe_add_key = self._Observable.new(dict.ObserveAddKey, self._observers)
	self._observe_remove_key = self._Observable.new(dict.ObserveRemoveKey, self._observers)
	self._observer_update_value = self._Observable.new(dict.ObserveUpdateValue, self._observers)

func ObserveCountChanged(notify_current_count : bool = false) -> Observable:
	return self._dict.ObserveCountChanged(notify_current_count)

func to_dict() -> Dictionary:
	if self.is_disposed:
		DisposedError.raise()
		return {}
	return self._dict.to_dict()

func find_key(value) -> Variant:
	if self.is_disposed:
		DisposedError.raise()
		return null
	return self._dict.find_key(value)

func get_value(key, default = null) -> Variant:
	if self.is_disposed:
		DisposedError.raise()
		return null
	return self._dict.get_value(key, default)

func has_key(key) -> bool:
	if self.is_disposed:
		DisposedError.raise()
		return false
	return self._dict.has_key(key)

func has_all(keys : Array) -> bool:
	if self.is_disposed:
		DisposedError.raise()
		return false
	return self._dict.has_all(keys)

func hash() -> int:
	if self.is_disposed:
		DisposedError.raise()
		return 0
	return self._dict.hash()

func is_empty() -> bool:
	if self.is_disposed:
		DisposedError.raise()
		return false
	return self._dict.is_empty()

func keys() -> Array:
	if self.is_disposed:
		DisposedError.raise()
		return []
	return self._dict.keys()

func size() -> int: 
	if self.is_disposed:
		DisposedError.raise()
		return -1
	return self._dict.size()

func values() -> Array:
	if self.is_disposed:
		DisposedError.raise()
		return []
	return self._dict.value()

func dispose():
	if this.is_disposed:
		return
	this.is_disposed = true
	for observer in this._observers:
		observer.on_completed()
