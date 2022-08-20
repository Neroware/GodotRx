class_name IterableBase

## A naive iterator type
##
## This interface provides a function to iterate over containers.

## Returns next element in the iterable sequence. Return instance of 
## [IterableBase.End] when end is reached.
func next() -> Variant:
	push_error("No implementation here!")
	return null

## Marks end of sequence.
class End: pass
