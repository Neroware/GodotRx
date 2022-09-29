class_name WeakKeyDictionary

## A dictionary with weak references to keys
##
## Pairs with non-referenced keys are automatically removed in a gargabe collection
## step

class _Pair:
	class LostRef:
		pass
	
	var _key # WeakRef or non-Object
	var _value : Variant
	var _wrapped : bool
	
	func _init(key_, value_):
		if key_ is Object:
			self._wrapped = true
			self._key = weakref(key_)
		else:
			self._wrapped = false
			self._key = key_
		self._value = value_
	
	func key():
		if self._wrapped:
			var ret = self._key.get_ref()
			return ret if ret != null else LostRef.new()
		return self._key
	
	func value():
		return self._value
	
	func is_valid() -> bool:
		return !(key() is LostRef)

var _data : Array
var _buffer_size : int

func _init(from : Dictionary = {}, buffer_size : int = 128):
	self._data = []
	self._buffer_size = buffer_size
	for idx in range(buffer_size):
		self._data.append(null)
	for key in from.keys():
		set_pair(key, from[key], false)

func _hash_index(key) -> int:
	return hash(key) % self._buffer_size

func _collect_garbage():
	for idx in range(self._data.size()):
		var col_lst = self._data[idx]
		if col_lst == null:
			continue
		var new_lst = []
		for pair in col_lst:
			if pair.is_valid():
				new_lst.append(pair)
		self._data[idx] = new_lst

func clear():
	for idx in range(self._buffer_size):
		self._data[idx] = null

func duplicate(gc : bool = true) -> WeakKeyDictionary:
	if gc: _collect_garbage()
	var ret = WeakKeyDictionary.new()
	ret._data = self._data.duplicate(true)
	ret._buffer_size = self._buffer_size
	return ret

func erase(key, gc : bool = true) -> bool:
	if gc: _collect_garbage()
	var idx = _hash_index(key)
	var col_lst = self._data[idx]
	if col_lst == null:
		return false
	for col_idx in range(col_lst.size()):
		var pair : _Pair = col_lst[col_idx]
		if pair.key() == key:
			col_lst.remove_at(col_idx)
			return true
	return false

func find_key(value, gc : bool = true) -> Variant:
	if gc: _collect_garbage()
	for col_lst in self._data:
		if col_lst == null:
			continue
		for pair_ in col_lst:
			var pair : _Pair = pair_
			if not pair.value() == value:
				continue
			var key = pair.key()
			if !(key is _Pair.LostRef):
				return key
	return null

func get_value(key, default = null, gc : bool = true) -> Variant:
	if gc: _collect_garbage()
	var idx = _hash_index(key)
	var col_lst = self._data[idx]
	if col_lst == null:
		return default
	for col_idx in range(col_lst.size()):
		var pair : _Pair = col_lst[col_idx]
		var k = pair.key()
		if key == k:
			return pair.value()
	return default

func has(key, gc : bool = true) -> bool:
	if gc: _collect_garbage()
	var idx = _hash_index(key)
	var col_lst = self._data[idx]
	if col_lst == null:
		return false
	for col_idx in range(col_lst.size()):
		var pair : _Pair = col_lst[col_idx]
		var k = pair.key()
		if key == k:
			return true
	return false

func has_all(keys_ : Array, gc : bool = true):
	if gc: _collect_garbage()
	return keys_.all(func(elem): return has(elem, false))

@warning_ignore(shadowed_global_identifier)
func hash() -> int:
	return self._data.hash()

func is_empty(gc : bool = true) -> bool:
	if gc: _collect_garbage()
	return self._data.all(func(elem): return (elem == null or elem.is_empty()))

func keys(gc : bool = true) -> Array:
	if gc: _collect_garbage()
	var _keys = []
	for col_lst in self._data:
		if col_lst == null:
			continue
		for pair in col_lst:
			var key = pair.key()
			if !(key is _Pair.LostRef):
				_keys.append(key)
	return _keys

func merge(dictionary : WeakKeyDictionary, overwrite : bool = false, gc : bool = true):
	if gc: _collect_garbage()
	for key in dictionary.keys():
		if not has(key, false) or (has(key, false) and overwrite):
			set_pair(key, dictionary.get_value(key, false), false)

func size(gc : bool = true) -> int:
	return keys(gc).size()

func values(gc : bool = true) -> Array:
	if gc: _collect_garbage()
	var vs = []
	for col_lst in self._data:
		if col_lst == null:
			continue
		for pair in col_lst:
			vs.append(pair.value())
	return vs

func set_pair(key, value, gc : bool = true):
	if gc: _collect_garbage()
	var idx = _hash_index(key)
	var col_lst = self._data[idx]
	if col_lst == null:
		self._data[idx] = [_Pair.new(key, value)]
		return
	for col_idx in range(col_lst.size()):
		var pair : _Pair = col_lst[col_idx]
		var k = pair.key()
		if k == key:
			col_lst[col_idx] = _Pair.new(key, value)
			return
	self._data[idx].append(_Pair.new(key, value))
