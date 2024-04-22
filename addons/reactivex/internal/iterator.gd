extends IteratorBase
class_name Iterator

## A naive iterator with additional quality-of-life utility
## 
## See [IteratorBase] and [IterableBase] for more info!

## Loops over all elements within the iterable sequence
func foreach(what : Callable = func(__elem): pass):
	var next_ = self.next()
	while not next_ is ItEnd:
		var continue_ = what.call(next_)
		if continue_ == false:
			break
		next_ = self.next()

## Loops and enumerates an iterable sequence
func enumerate(what : Callable = func(__elem, __idx : int): pass):
	var idx_ = 0
	var next_ = self.next()
	while not next_ is ItEnd:
		var continue_ = what.call(next_, idx_)
		if continue_ == false:
			break
		idx_ += 1
		next_ = self.next()


## An iterable working on an [Array] or a relative like [PackedByteArray]
class ArrayIterable extends IterableBase:
	var _x
	
	var _start : int
	var _end : int
	
	func _init(x, start : int = 0, end : int = -1):
		self._x = x
		self._start = start
		self._end = x.size() if end < 0 else end
		
		if self._start < 0 or self._start > self._end or self._end > x.size():
			ArgumentOutOfRangeError.raise()
			return
	
	class _Iterator extends Iterator:
		var _itx
		var _itstart : int
		var _itend : int
		
		var _itindex : int
		
		func _init(x, start : int, end : int):
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


## An iterable working on a [Dictionary]
class DictionaryIterable extends IterableBase:
	var _dict : Dictionary
	
	func _init(dict : Dictionary):
		self._dict = dict
	
	class _Iterator extends Iterator:
		var _itdict : Dictionary
		
		var _itindex : int
		var _itend : int
		var _itkeys : Array
		
		func _init(dict : Dictionary):
			self._itdict = dict
			self._itindex = 0
			self._itend = dict.size()
			self._itkeys = dict.keys()
		
		func has_next() -> bool:
			return not (self._itdict.is_empty() or self._itindex == self._itend) 
		
		func next() -> Variant:
			if not has_next():
				return ItEnd.new()
			self._itindex += 1
			return Tuple.new([
				self._itkeys[self._itindex - 1],
				self._itdict[self._itkeys[self._itindex - 1]]
			])
		
		func empty() -> bool:
			return self._itdict.is_empty()
	
	func iter() -> Iterator:
		return self._Iterator.new(self._dict)

## Anonymous [IterableBase]
class _Iterable extends IterableBase:
	var seq
	func _init(seq_):
		self.seq = seq_
	func iter() -> Iterator:
		return seq.iter()

## Constructs an iterable sequence of type [IterableBase] based on x.
static func to_iterable(x : Variant) -> IterableBase:
	if x is Array or x is PackedByteArray or x is PackedColorArray or x is PackedFloat32Array or x is PackedFloat64Array or x is PackedInt32Array or x is PackedInt64Array or x is PackedStringArray or x is PackedVector2Array or x is PackedVector3Array:
		return ArrayIterable.new(x)
	if x is Dictionary:
		return DictionaryIterable.new(x)
	if x is IterableBase:
		return x
	if x.has_method("iter"):
		return _Iterable.new(x)
	return to_iterable([x])

## Returns an [Iterator] onto the given sequence.
static func iter(x) -> Iterator:
	return to_iterable(x).iter()
