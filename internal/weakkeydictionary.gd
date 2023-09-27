class_name WeakKeyDictionary

## A dictionary with weak references to keys
## 
## Pairs with non-referenced keys are automatically removed when deleted.
## Each [b]n[/b] insertions, a garbage collection step is performed.

var _data : Dictionary
var _lock : ReadWriteLock

var n : int
var _count : int

func _init(from : Dictionary = {}, n_insertions : int = 100):
	self._data = {}
	self._lock = ReadWriteLock.new()
	for key in from.keys():
		set_pair(key, from[key])

	self.n = n_insertions
	self._count = 0

func _hash_key(key) -> int:
	return hash(key)

func _collect_garbage():
	var dead_keys : Array = []
	for hkey in self._data.keys():
		if self._data[hkey].at(0).get_ref() == null:
			dead_keys.push_back(hkey)
	for hkey in dead_keys:
		self._data.erase(hkey)

func set_pair(key, value):
	if GDRx.assert_(key != null, "Key is NULL!"):
		return
	if GDRx.assert_(key is Object, "Key needs to be of type 'Object'"):
		return
	var hkey = self._hash_key(key)
	
	var __ = ReadWriteLockGuard.new(self._lock, false)
	self._data[hkey] = Tuple.new([weakref(key), value])
	self._count += 1
	if self._count >= n:
		self._count = 0
		self._collect_garbage()

func get_value(key, default = null) -> Variant:
	if GDRx.assert_(key != null, "Key is NULL!"):
		return
	if GDRx.assert_(key is Object, "Key needs to be of type 'Object'"):
		return
	var hkey = self._hash_key(key)
	
	var __ = ReadWriteLockGuard.new(self._lock, true)
	if self._data.has(hkey):
		return self._data[hkey].at(1)
	return default

func find_key(value) -> Variant:
	var __ = ReadWriteLockGuard.new(self._lock, true)
	for tup in self._data.values():
		if GDRx.eq(tup.at(1), value):
			return tup.at(0).get_ref()
	return null

func to_hash() -> int:
	var __ = ReadWriteLockGuard.new(self._lock, true)
	return self._data.hash()

func is_empty() -> bool:
	var __ = ReadWriteLockGuard.new(self._lock, true)
	return self._data.is_empty()

func clear():
	var __ = ReadWriteLockGuard.new(self._lock, false)
	self._data.clear()
	self._count = 0

func erase(key) -> bool:
	if GDRx.assert_(key != null, "Key is NULL!"):
		return false
	if GDRx.assert_(key is Object, "Key needs to be of type 'Object'"):
		return false
	var hkey = self._hash_key(key)
	
	var __ = ReadWriteLockGuard.new(self._lock, false)
	return self._data.erase(hkey)

func values() -> Array:
	var res : Array = []
	var __ = ReadWriteLockGuard.new(self._lock, true)
	for tup in self._data.values():
		res.push_back(tup.at(1))
	return res

func size() -> int:
	var __ = ReadWriteLockGuard.new(self._lock, true)
	return self._data.size()

func keys() -> Array:
	var res : Array = []
	var __ = ReadWriteLockGuard.new(self._lock, true)
	for tup in self._data.values():
		var key = tup.at(0).get_ref()
		if key:
			res.push_back(key)
	return res

func has_key(key) -> bool:
	if GDRx.assert_(key != null, "Key is NULL!"):
		return false
	if GDRx.assert_(key is Object, "Key needs to be of type 'Object'"):
		return false
	var hkey = self._hash_key(key)
	
	var __ = ReadWriteLockGuard.new(self._lock, true)
	return self._data.has(hkey)

func has_all(keys_ : Array) -> bool:
	var _keys = keys_.duplicate()
	_keys.all(func(elem): return self._hash_key(elem))
	var __ = ReadWriteLockGuard.new(self._lock, true)
	return self._data.has_all(_keys)
