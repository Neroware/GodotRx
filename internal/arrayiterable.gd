extends IterableBase
class_name ArrayIterable

## An iterable working on an array

var _x : Array

var _start : int
var _end : int

func _init(x : Array, start : int = 0, end : int = -1):
	self._x = x
	self._start = start
	self._end = x.size() if end < 0 else end
	
	if self._start < 0 or self._start > self._end or self._end > x.size():
		GDRx.exc.ArgumentOutOfRangeException.Throw()
		return

class _Iterator extends Iterator:
	var _itx : Array
	var _itstart : int
	var _itend : int
	
	var _itindex : int
	
	func _init(x : Array, start : int, end : int):
		self._itx = x
		self._itstart = start
		self._itend = end
		self._itindex = start
	
	func has_next() -> bool:
		return not (self._itx.is_empty() or self._itindex == self._itend) 
	
	func next() -> Variant:
		if not has_next():
			return ItEnd.new()
		self._itindex += 1
		return self._itx[self._itindex - 1]
	
	func front() -> Variant:
		return ItEnd.new() if self._itx.is_empty() else self._itx[self._itstart]
	
	func back() -> Variant:
		return ItEnd.new() if self._itx.is_empty() else self._itx[self._itend - 1]
	
	func empty() -> bool:
		return self._itx.is_empty()
	
	func at(n : int) -> Variant:
		var it = _Iterator.new(self._itx, self._itstart, self._itend)
		var tmp = ItEnd.new()
		for i in range(n):
			tmp = it.next()
		return tmp

func iter() -> Iterator:
	return self._Iterator.new(self._x, self._start, self._end)
