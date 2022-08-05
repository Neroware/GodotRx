extends IterableBase
class_name ArrayIterator

var _x : Array

var _index : int
var _end : int

func _init(x : Array, start : int = 0, end : int = -1):
	self._x = x
	self._index = start
	if end < 0:
		self._end = x.size()
	else:
		self._end = end

func next() -> Variant:
	if self._index == self._end:
		return self.End.new()
	self._index += 1
	return self._x[self._index - 1]
