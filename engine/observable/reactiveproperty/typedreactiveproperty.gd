extends ReactiveProperty
class_name ReactivePropertyT

var _basic_type : bool
var _type

var T:
	get: return self._type

func _init(
	initial_value_,
	type_ = TYPE_MAX,
	distinct_until_changed_ : bool = true,
	raise_latest_value_on_subscribe_ : bool = true,
	source : Observable = null
):
	if type_ is int:
		self._basic_type = true
	elif type_ is GDScript:
		self._basic_type = false
	else:
		var msg = "Type specifier of a typed ReactiveProperty needs to be [GDScript] or [int]!"
		GDRx.exc.BadArgumentException.new(msg).throw()
		return
	self._type = type_
	super._init(initial_value_, distinct_until_changed_, raise_latest_value_on_subscribe_, source)

func _set_value(value):
	if self._basic_type and typeof(value) != self._type:
		GDRx.exc.TypeMismatchException.new(value).throw()
		return
	if not self._basic_type and not value is self._type:
		GDRx.exc.TypeMismatchException.new(value).throw()
		return
	super._set_value(value)
