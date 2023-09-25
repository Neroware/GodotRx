extends Comparable
class_name Tuple

## A Tuple based on a list

var _x : Array

static func Empty() -> Tuple:
	return Tuple.new([])

func _init(x : Array):
	self._x = x

func _to_string():
	var s = "( "
	for elem in self._x:
		s += str(elem) + " "
	s += ")"
	return s

func at(i : int):
	return _x[i]

func as_list() -> Array:
	return _x.duplicate()

func iter() -> Iterator:
	return Iterator.iter(self._x)

func is_empty() -> bool:
	return self._x.is_empty()

func gt(other) -> bool:
	if not (other is Tuple):
		return false
	return (self._x.is_empty() and other._x.is_empty()) \
	or GDRx.gt(self._x[0], other._x[0])

func eq(other) -> bool:
	if not (other is Tuple):
		return false
	return (self._x.is_empty() and other._x.is_empty()) \
	or GDRx.eq(self._x[0], other._x[0])

func lt(other) -> bool:
	if not (other is Tuple):
		return false
	return (self._x.is_empty() and other._x.is_empty()) \
	or GDRx.lt(self._x[0], other._x[0])
