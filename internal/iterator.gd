extends IterableBase
class_name Iterator

## A naive iterator type
##
## This interface provides a function to iterate over iterable sequences.

var _it : IterableBase

func _init(it_ : IterableBase):
	self._it = it_

func next() -> Variant:
	return self._it.next()

func iter():
	return self._it.iter()

## Loops over all elements within the iterable sequence
func foreach(what : Callable = func(__elem): pass):
	var next_ = self.next()
	while not next_ is ItEnd:
		var continue_ = what.call(next_)
		if continue_ == false:
			break
		next_ = self.next()
