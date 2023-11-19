extends ReadOnlyReactiveProperty
class_name ReadOnlyReactivePropertyT

var _type
var T:
	get: return self._type

func _init(
	source : ReactivePropertyT,
	initial_value_,
	distinct_until_changed_ : bool = true,
	raise_latest_value_on_subscribe_ : bool = true
):
	self._type = source.T
	super._init(source, initial_value_, distinct_until_changed_, raise_latest_value_on_subscribe_)
