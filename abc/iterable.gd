class_name IterableBase

## A naive iterable type
##
## This interface provides a function to iterate over containers.

## Returns next element in the iterable sequence. Return instance of 
## [ItEnd] when end is reached.
func next() -> Variant:
	GDRx.exc.NotImplementedException.Throw()
	return null

## Returns an iterator onto the given iterable sequence. The contents are NOT
## duplicates!
func iter() -> Iterator:
	GDRx.exc.NotImplementedException.Throw()
	return null
