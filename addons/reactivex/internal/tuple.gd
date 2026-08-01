extends Comparable
class_name Tuple

## A Tuple based on a list

var _x : Array

var empty : bool:
	get: return self.is_empty()
var first:
	get: return _x[0] if _x.size() > 0 else GDRx.raise_message("Out of bounds")
var second:
	get: return _x[1] if _x.size() > 1 else GDRx.raise_message("Out of bounds")
var third:
	get: return _x[2] if _x.size() > 2 else GDRx.raise_message("Out of bounds")
var fourth:
	get: return _x[3] if _x.size() > 3 else GDRx.raise_message("Out of bounds")
var fifth:
	get: return _x[4] if _x.size() > 4 else GDRx.raise_message("Out of bounds")
var sixth:
	get: return _x[5] if _x.size() > 5 else GDRx.raise_message("Out of bounds")
var seventh:
	get: return _x[6] if _x.size() > 6 else GDRx.raise_message("Out of bounds")
var eighth:
	get: return _x[7] if _x.size() > 7 else GDRx.raise_message("Out of bounds")

static func Empty() -> Tuple:
	return Tuple.new([])

func _init(x : Array):
	self._x = x.duplicate()
	self._x.make_read_only()

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

func eq(other) -> bool:
	if not (other is Tuple):
		return false
	if self._x.size() != other._x.size():
		return false
	for i in range(self._x.size()):
		if not GDRx.eq(self._x[i], other._x[i]):
			return false
	return true

func lt(other) -> bool:
	if not (other is Tuple):
		return false
	var n = min(self._x.size(), other._x.size())
	for i in range(n):
		if GDRx.lt(self._x[i], other._x[i]):
			return true
		if GDRx.lt(other._x[i], self._x[i]):
			return false
	return self._x.size() < other._x.size()

func gt(other) -> bool:
	if not (other is Tuple):
		return false
	return other.lt(self)

var __it__ : Iterator
var __curr__ : Variant

func _iter_init(arg):
	self.__it__ = iter()
	var continue_ = self.__it__.has_next()
	self.__curr__ = self.__it__.next()
	return continue_

func _iter_next(arg):
	var continue_ = self.__it__.has_next()
	self.__curr__ = self.__it__.next()
	return continue_

func _iter_get(arg):
	return self.__curr__
