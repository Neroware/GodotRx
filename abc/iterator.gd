class_name IteratorBase

## An iterator type
##
## An [IteratorBase] iterates over an [IterableBase] using [method next].

## Returns next element in the iterable sequence. Return instance of 
## [ItEnd] when end is reached.
func next() -> Variant:
	GDRx.exc.NotImplementedException.Throw()
	return null

## Return 'true' if the sequence has another element.
func has_next() -> bool:
	GDRx.exc.NotImplementedException.Throw()
	return false

## Returns the first element within the sequence
func front() -> Variant:
	GDRx.exc.NotImplementedException.Throw()
	return null

## Returns the last element within the sequence
func back() -> Variant:
	GDRx.exc.NotImplementedException.Throw()
	return null

## Returns 'true' if the iterable sequence is empty.
func empty() -> bool:
	GDRx.exc.NotImplementedException.Throw()
	return false

## Returns the n-th element within the sequence.
func at(n : int) -> Variant:
	GDRx.exc.NotImplementedException.Throw()
	return false
