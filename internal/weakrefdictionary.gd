class_name WeakRefDictionary

## A dictionary with only weak-key-references.

var _data : Dictionary

func _init(from : Dictionary = {}):
	self._data = {}
	for key in from.keys():
		var item = from[key]
		if not item is Object:
			push_error("Godot only supports WeakRef to classes extending Object!")
			continue
		else:
			self._data[key] = weakref(item)

func clear():
	self._data.clear()

func duplicate(deep : bool = false) -> WeakRefDictionary:
	var ret = WeakRefDictionary.new()
	ret._data = self._data.duplicate(deep)
	return ret

func erase(key) -> bool:
	return self._data.erase(key)

func get(key, default = null) -> Variant:
	var ret = self._data.get(key, default)
	if ret is WeakRef:
		return ret.get_ref()
	return ret

func set_pair(key, value):
	if not value is Object:
		push_error("Godot only supports WeakRef to classes extending Object!")
		return
	self._data[key] = weakref(value)

func has(key) -> bool:
	return self._data.has(key)

func has_all(keys : Array) -> bool:
	return self._data.has_all(keys)

func hash() -> int:
	return self._data.hash()

func is_empty() -> bool:
	return self._data.is_empty()

func keys() -> Array:
	return self._data.keys()

func merge(dictionary : WeakRefDictionary, overwrite : bool = false):
	self._data.merge(dictionary._data, overwrite)

func size() -> int:
	return self._data.size()

func values() -> Array:
	return self._data.values()
