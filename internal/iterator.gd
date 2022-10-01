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
