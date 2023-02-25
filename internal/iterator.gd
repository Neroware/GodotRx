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
