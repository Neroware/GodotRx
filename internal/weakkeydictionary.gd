class_name WeakKeyDictionary

## A dictionary with weak references to keys
##
## Pairs with non-referenced keys are automatically removed in a gargabe collection
## step

var _data : Dictionary
var _weakkeys : Dictionary
var _lock : ReadWriteLock

## At this size, a garbage collection step is performed when a pair is added
const GARBAGE_COLLECTION_SIZE : int = 1000

func _init(from : Dictionary = {}):
	self._data = {}
	self._weakkeys = {}
	self._lock = ReadWriteLock.new()
	for key in from.keys():
		set_pair(key, from[key])

func _hash_key(key) -> int:
	return hash(key)

func _collect_lost_references():
	for hkey in self._weakkeys.keys():
		var wkey = self._weakkeys[hkey].get_ref()
		if wkey != null:
			continue
		self._weakkeys.erase(hkey)
		self._data.erase(hkey)

func set_pair(key, value):
	if GDRx.assert_(key != null, "Key is NULL!"):
		return
	if GDRx.assert_(key is Object, "Key needs to be of type 'Object'"):
		return
	
	if self._weakkeys.size() > GARBAGE_COLLECTION_SIZE:
		self._lock.w_lock()
		_collect_lost_references()
		self._lock.w_unlock()
	
	var hkey = self._hash_key(key)
	
	self._lock.w_lock()
	self._data[hkey] = value
	self._weakkeys[hkey] = weakref(key)
	self._lock.w_unlock()

func get_value(key, default = null) -> Variant:
	var res = null
	
	self._lock.r_lock()
	res = self._data.get(self._hash_key(key), default)
	self._lock.r_unlock()
	
	return res

func find_key(value) -> Variant:
	var res = null
	
	self._lock.r_lock()
	var hkey = self._data.find_key(value)
	if hkey == null:
		self._lock.r_unlock()
		return null
	var wkey = self._weakkeys.get(hkey)
	if wkey == null:
		self._lock.r_unlock()
		return null
	res = wkey.get_ref()
	self._lock.r_unlock()
	
	return res

func to_hash() -> int:
	var res : int = 0
	
	self._lock.r_lock()
	res = self._data.hash()
	self._lock.r_unlock()
	
	return res

func is_empty() -> bool:
	var res : bool = true
	
	self._lock.r_lock()
	res = self._data.is_empty()
	self._lock.r_unlock()
	
	return res

func clear():
	self._lock.w_lock()
	self._data.clear()
	self._weakkeys.clear()
	self._lock.w_unlock()

func duplicate(deep : bool = false):
	var copy : WeakKeyDictionary = WeakKeyDictionary.new()
	self._lock.r_lock()
	copy._data = self._data.duplicate(deep)
	copy._weakkeys = self._weakkeys.duplicate()
	self._lock.r_unlock()
	return copy

func erase(key) -> bool:
	var res : bool = false
	var hkey = self._hash_key(key)
	
	self._lock.w_lock()
	self._weakkeys.erase(hkey)
	res = self._data.erase(hkey)
	self._lock.w_unlock()
	
	return res

func values() -> Array:
	var res : Array
	
	self._lock.r_lock()
	res = self._data.values()
	self._lock.r_unlock()
	
	return res

func size() -> int:
	var res : int = 0
	
	self._lock.r_lock()
	res = self._data.size()
	self._lock.r_unlock()
	
	return res

func merge(dictionary : WeakKeyDictionary, overwrite : bool = false):
	self._lock.w_lock()
	self._weakkeys.merge(dictionary._weakkeys, overwrite)
	self._data.merge(dictionary._data, overwrite)
	self._lock.w_unlock()

func keys() -> Array:
	var res = []
	
	self._lock.r_lock()
	var wkeys = self._weakkeys.duplicate().values()
	for wkey in wkeys:
		var key_ = wkey.get_ref()
		if key_ != null:
			res.append(key_)
	self._lock.r_unlock()
	
	return res

func has_key(key) -> bool:
	var res : bool = false
	
	self._lock.r_lock()
	res = self._data.has(self._hash_key(key))
	self._lock.r_unlock()
	
	return res

func has_all(keys_ : Array) -> bool:
	var res : bool = false
	
	self._lock.r_lock()
	var _keys = keys_.duplicate()
	_keys.all(func(elem): return self._hash_key(elem))
	res = self._data.has_all(_keys)
	self._lock.r_unlock()
	
	return res
