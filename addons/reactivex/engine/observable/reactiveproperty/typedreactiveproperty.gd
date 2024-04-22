extends ReactiveProperty
class_name ReactivePropertyT

var _type
var _type_equality : Callable

var _push_type_err : bool

var T:
	get: return self._type

func _init(
	initial_value_,
	type_ = TYPE_MAX,
	distinct_until_changed_ : bool = true,
	raise_latest_value_on_subscribe_ : bool = true,
	source : Observable = null,
	push_type_err : bool = true,
	type_equality : Callable = GDRx.basic.default_type_equality
):
	self._type = type_
	self._push_type_err = push_type_err
	self._type_equality = type_equality
	super._init(initial_value_, distinct_until_changed_, raise_latest_value_on_subscribe_, source)

func _type_check_fail(value, default = null):
	var exc = TypeMismatchError.new(value)
	if self._push_type_err: push_error(exc)
	exc.throw(value)
	return default

func _set_value(value):
	if not self._type_equality.call(self._type, value):
		self._type_check_fail(value)
		return
	super._set_value(value)

func to_readonly() -> ReadOnlyReactiveProperty:
	return ReadOnlyReactivePropertyT.new(
		self, Value, self._distinct_until_changed, 
		self._raise_latest_value_on_subscribe
	)

func to_typed_readonly() -> ReadOnlyReactivePropertyT:
	return self.to_readonly() as ReadOnlyReactivePropertyT
