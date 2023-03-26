class_name WeakKeyDictionary

## A dictionary with weak references to keys
##
## Pairs with non-referenced keys are automatically removed when deleted.

var _data : Dictionary
var _weakkeys : Dictionary

func _init(from : Dictionary = {}):
	self._data = {}
	self._weakkeys = {}
	for key in from.keys():
		set_pair(key, from[key])

func _hash_key(key) -> int:
	return hash(key)

func _set_pair(hkey : int, wkey : WeakRef, value):
	self._weakkeys[hkey] = wkey
	self._data[hkey] = value

func _remove_pair(hkey : int) -> bool:
	return self._weakkeys.erase(hkey) and self._data.erase(hkey)

func _add_disposer(key : Object, hkey : int):
	var ref : WeakRef = weakref(self)
	var on_dispose = func():
		var d : WeakKeyDictionary = ref.get_ref()
		if d == null:
			return
		d._remove_pair(hkey)
	AutoDisposer.Add(key, Disposable.new(on_dispose))

func set_pair(key, value):
	if GDRx.assert_(key != null, "Key is NULL!"):
		return
	if GDRx.assert_(key is Object, "Key needs to be of type 'Object'"):
		return
	var hkey : int = self._hash_key(key)
	var wkey : WeakRef = weakref(key)
	self._set_pair(hkey, wkey, value)
	self._add_disposer(key, hkey)

func get_value(key, default = null) -> Variant:
	return self._data.get(self._hash_key(key), default)

func find_key(value) -> Variant:
	var hkey = self._data.find_key(value)
	if hkey == null:
		return null
	var wkey : WeakRef = self._weakkeys.get(hkey)
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

func erase(key) -> bool:
	var hkey : int = self._hash_key(key)
	return self._remove_pair(hkey)

func values() -> Array:
	return self._data.values()

func size() -> int:
	return self._data.size()

func keys() -> Array:
	var res = []
	var hkeys = self._weakkeys.keys()
	for hkey in hkeys:
		var wkey : WeakRef = self._weakkeys[hkey]
		if wkey == null:
			continue
		var key = wkey.get_ref()
		if key == null:
			continue
		res.push_back(key)
	return res

func has_key(key) -> bool:
	return self._data.has(self._hash_key(key))

func has_all(keys_ : Array) -> bool:
	var _keys = keys_.duplicate()
	_keys.all(func(elem): return self._hash_key(elem))
	return self._data.has_all(_keys)
