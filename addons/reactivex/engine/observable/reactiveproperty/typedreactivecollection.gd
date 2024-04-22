extends ReactiveCollection
class_name ReactiveCollectionT

var _type
var _type_equality : Callable

var _push_type_err : bool

var T:
	get: return self._type

func _init(collection = [], type_ = TYPE_MAX, push_type_err : bool = true, type_equality : Callable = GDRx.basic.default_type_equality):
	self._type = type_
	self._push_type_err = push_type_err
	self._type_equality = type_equality
	super._init(collection)

func _type_check(value) -> bool:
	return not self._type_equality.call(self._type, value)

func _type_check_fail(value, default = null):
	var exc = TypeMismatchError.new(value)
	if self._push_type_err: push_error(exc)
	exc.throw(value)
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

func to_readonly() -> ReadOnlyReactiveCollection:
	return ReadOnlyReactiveCollectionT.new(self)

func to_typed_readonly() -> ReadOnlyReactiveCollectionT:
	return self.to_readonly() as ReadOnlyReactiveCollectionT
