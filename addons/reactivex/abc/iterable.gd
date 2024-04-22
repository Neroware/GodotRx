class_name IterableBase

## An iterable type
## 
## An [IterableBase] constructs an [IteratorBase] to iterate over it.
## This is done using the [method iter] method.

## Returns an iterator onto the given iterable sequence.
func iter() -> Iterator:
	NotImplementedError.raise()
	return null
