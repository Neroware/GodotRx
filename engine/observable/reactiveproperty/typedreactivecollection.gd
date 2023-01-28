extends ReactiveCollection
class_name ReactiveCollectionT

var _basic_type : bool
var _type

var T:
	get: return self._type

func _init(collection = [], type_ = TYPE_MAX):
	if type_ is int:
		self._basic_type = true
	elif type_ is GDScript:
		self._basic_type = false
	else:
		var msg = "Type specifier of a typed ReactiveProperty needs to be [GDScript] or [int]!"
		GDRx.exc.BadArgumentException.new(msg).throw()
		return
	self._type = type_
	super._init(collection)

func _type_check(value) -> bool:
	return (self._basic_type and typeof(value) != self._type) or \
		(not self._basic_type and not value is self._type)

func _type_check_fail(value, default = null):
	GDRx.exc.TypeMismatchException.new(value).throw(value)
	return default

func add_item(item) -> int:
	if self._type_check(item):
		return self._type_check_fail(item, -1)
	return super.add_item(item)

func remove_item(item) -> int:
	if self._type_check(item):
		return self._type_check_fail(item, -1)
	return super.remove_item(item)

func replace_item(item, with) -> int:
	if self._type_check(item):
		return self._type_check_fail(item, -1)
	if self._type_check(with):
		return self._type_check_fail(with, -1)
	return super.replace_item(item, with)

func replace_at(index : int, item) -> Variant:
	if self._type_check(item):
		return self._type_check_fail(item)
	return super.replace_at(index, item)

func insert_at(index : int, item):
	if self._type_check(item):
		self._type_check_fail(item)
		return
	super.insert_at(index, item)

func find(item) -> int:
	if self._type_check(item):
		return self._type_check_fail(item, -1)
	return super.find(item)
