extends Comparable
class_name Tuple

var _x : Array

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

func gt(other) -> bool:
	if not other is Tuple:
		return false
	if _x[0] is Comparable:
		return _x[0].gt(other.at(0))
	return _x[0] > other.at(0)

func eq(other) -> bool:
	if not other is Tuple:
		return false
	if _x[0] is Comparable:
		return _x[0].eq(other.at(0))
	return _x[0] == other.at(0)

func lt(other) -> bool:
	if not other is Tuple:
		return false
	if _x[0] is Comparable:
		return _x[0].lt(other.at(0))
	return _x[0] < other.at(0)
