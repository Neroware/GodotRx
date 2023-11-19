extends IterableBase
class_name InfiniteIterable

## Represents a never ending iterable sequence

var _infval

func _init(infval = GDRx.util.NOT_SET):
	self._infval = infval

class _Iterator extends Iterator:
	var _itcounter : int
	var _itinfval
	
	func _init(infval):
		self._itinfval = infval
		self._itcounter = 0
	
	func has_next() -> bool:
		return true
	
	func next() -> Variant:
		self._itcounter += 1
		if not is_instance_of(self._itinfval, GDRx.util.NotSet):
			return self._itinfval
		return self._itcounter
	
	func empty() -> bool:
		return false
	
	func front() -> Variant:
		return self.next()
	
	func back() -> Variant:
		return GDRx.raise_message("This pain persists, I can't resist... but that's what it takes to be INFINITE!")
	
	func at(n : int) -> Variant:
		if not is_instance_of(self._itinfval, GDRx.util.NotSet):
			return self._itinfval
		return n + 1

func iter() -> Iterator:
	return self._Iterator.new(self._infval)
