extends IterableBase
class_name WhileIterable

## Represents an infinite or finite sequence which is terminated when a 
## condition is not met anymore.

var _it : IterableBase
var _cond : Callable

func _init(it : IterableBase, cond : Callable = GDRx.basic.default_condition):
	self._it = it
	self._cond = cond

class _Iterator extends Iterator:
	var _itit : Iterator
	var _itcond : Callable
	
	func _init(it : Iterator, cond : Callable):
		self._itit = it
		self._itcond = cond
	
	func has_next() -> bool:
		return self._itit.has_next() or not self._itcond.call()
	
	func next() -> Variant:
		return ItEnd.new() if not self._itcond.call() else self._itit.next()

func iter() -> Iterator:
	return self._Iterator.new(self._it.iter(), self._cond)
