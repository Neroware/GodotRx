class_name WeakKeyDictionary

## A dictionary with weak references to keys
##
## Pairs with non-referenced keys are automatically removed in a gargabe collection
## step

var _data : Dictionary
var _weakkeys : Dictionary
var _lock : RLock

## At this size, a garbage collection step is performed when a pair is added
const GARBAGE_COLLECTION_SIZE : int = 1000

func _init(from : Dictionary = {}):
	self._data = {}
	self._weakkeys = {}
	self._lock = RLock.new()
	for key in from.keys():
		set_pair(key, from[key])

func _hash_key(key) -> int:
	return hash(key)

func _collect_lost_references():
	self._lock.lock()
	
	for hkey in self._weakkeys.keys():
		var wkey = self._weakkeys[hkey].get_ref()
		if wkey != null:
			continue
		self._weakkeys.erase(hkey)
		self._data.erase(hkey)
	
	self._lock.unlock()

func set_pair(key, value):
	if GDRx.assert_(key is Object):
		return
	
	if self._weakkeys.size() > GARBAGE_COLLECTION_SIZE:
		_collect_lost_references()
	
	var hkey = self._hash_key(key)
	self._data[hkey] = value
	self._weakkeys[hkey] = weakref(key)

func get_value(key) -> Variant:
	return self._data.get(self._hash_key(key))

func find_key(value) -> Variant:
	var hkey = self._data.find_key(value)
	if hkey == null:
		return null
	var wkey = self._weakkeys.get(hkey)
	if wkey == null:
		return null
	return wkey.get_ref()

func to_hash() -> int:
	return self._data.hash()

func is_empty() -> bool:
	return self._data.is_empty()

func clear():
	self._data.clear()
	self._weakkeys.clear()

func duplicate(deep : bool = false):
	var copy : WeakKeyDictionary = WeakKeyDictionary.new()
	copy._data = self._data.duplicate(deep)
	copy._weakkeys = self._weakkeys.duplicate()
	return copy

func erase(key) -> bool:
	var hkey = self._hash_key(key)
	self._weakkeys.erase(hkey)
	return self._data.erase(hkey)

func values() -> Array:
	return self._data.values()

func size() -> int:
	return self._data.size()

func merge(dictionary : WeakKeyDictionary, overwrite : bool = false):
	self._weakkeys.merge(dictionary._weakkeys, overwrite)
	self._data.merge(dictionary._data, overwrite)

func keys() -> Array:
	var res = []
	var wkeys = self._weakkeys.duplicate().values()
	for wkey in wkeys:
		var key_ = wkey.get_ref()
		if key_ != null:
			res.append(key_)
	return res

func has_key(key) -> bool:
	return self._data.has(self._hash_key(key))

func has_all(keys_ : Array) -> bool:
	var _keys = keys_.duplicate()
	_keys.all(func(elem): return self._hash_key(elem))
	return self._data.has_all(_keys)
