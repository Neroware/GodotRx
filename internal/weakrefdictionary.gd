class_name WeakRefDictionary

## A dictionary with weak references to keys
##
## Pairs with non-valid keys are automatically removed in a gargabe collection
## step

var _data : Array
var _buffer_size : int

class _Pair:
	var _key # WeakRef or non-Object
	var _value : Variant
	
	var _wrapped : bool
	
	func _init(key, value):
		if key is Object:
			self._wrapped = true
			self._key = weakref(key)
		else:
			self._wrapped = false
			self._key = key
		self._value = value
	
	func is_valid():
		return not _wrapped or (_wrapped and _key.get_ref() != null)
	
	func key():
		if _wrapped:
			return _key.get_ref()
		return _key
	
	func value():
		return self._value

func _init(from : Dictionary = {}, buffer_size : int = 128):
	self._data = []
	self._buffer_size = buffer_size
	for idx in range(buffer_size):
		self._data.append(null)
	for key in from.keys():
		set_pair(key, from[key])

func _hash_index(key) -> int:
	return hash(key) % self._buffer_size

func clear():
	for idx in range(self._buffer_size):
		self._data[idx] = null

func duplicate() -> WeakRefDictionary:
	_collect_garbage()
	var ret = WeakRefDictionary.new()
	ret._data = self._data.duplicate(true)
	ret._buffer_size = self._buffer_size
	return ret

func erase(key) -> bool:
	_collect_garbage()
	var idx = _hash_index(key)
	var lst = self._data[idx]
	if lst == null:
		return false
	for col_idx in range(lst.size()):
		var pair : _Pair = lst[col_idx]
		if pair.is_valid() and pair.key() == key:
			lst.remove_at(col_idx)
			return true
	return false

func get(key) -> Variant:
	_collect_garbage()
	var idx = _hash_index(key)
	var lst = self._data[idx]
	if lst == null:
		return null
	for col_idx in range(lst.size()):
		var pair : _Pair = lst[col_idx]
		if pair.is_valid() and pair.key() == key:
			return pair.value()
	return null

func set_pair(key, value):
	_collect_garbage()
	var idx = _hash_index(key)
	var lst = self._data[idx]
	if lst == null:
		self._data[idx] = [_Pair.new(key, value)]
		return
	for col_idx in range(lst.size()):
		var pair : _Pair = lst[col_idx]
		if pair.is_valid() and pair.key() == key:
			lst[col_idx] = _Pair.new(key, value)
			return
	self._data[idx].append(_Pair.new(key, value))

func has(key) -> bool:
	_collect_garbage()
	var idx = _hash_index(key)
	var lst = self._data[idx]
	if lst == null:
		return false
	for col_idx in range(lst.size()):
		var pair : _Pair = lst[col_idx]
		if pair.is_valid() and pair.key() == key:
			return true
	return false

func has_all(keys : Array) -> bool:
	_collect_garbage()
	return keys.all(func(elem): return has(elem))

func hash():
	_collect_garbage()
	return self._data.hash()

func is_empty() -> bool:
	_collect_garbage()
	return self._data.all(func(elem): elem == null or elem.is_empty())

func keys() -> Array:
	_collect_garbage()
	var keys = []
	for lst in self._data:
		if lst == null:
			continue
		for pair in lst:
			if not pair.is_valid():
				continue
			keys.append(pair.key())
	return keys

func merge(dictionary : WeakRefDictionary, overwrite : bool = false):
	_collect_garbage()
	for key in dictionary.keys():
		if not has(key) or (has(key) and overwrite):
			set_pair(key, dictionary.get(key))

func size():
	_collect_garbage()
	return keys().size()

func values() -> Array:
	_collect_garbage()
	var vs = []
	for lst in self._data:
		if lst == null:
			continue
		for pair in lst:
			vs.append(pair.value())
	return vs

func _collect_garbage():
	for idx in range(self._data.size()):
		var lst = self._data[idx]
		if lst == null:
			continue
		var new_lst = []
		for pair in lst:
			if pair.is_valid():
				new_lst.append(pair)
		self._data[idx] = new_lst
