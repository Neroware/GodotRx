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

## Returns the first element within the sequence
func front():
	return self._it.iter().next()

## Returns the last element within the sequence
func end():
	var _end = RefValue.Set(ItEnd.new())
	self._it.iter().foreach(func(i): _end.v = i)
	return _end.v

## Returns the n-th element within the sequence
func at(n : int):
	var _end = RefValue.Set(ItEnd.new())
	self._it.iter().enumerate(func(i, idx): if idx == n: _end.v = i)
	return _end.v
