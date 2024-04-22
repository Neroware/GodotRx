class_name IteratorBase

## An iterator type
## 
## An [IteratorBase] iterates over an [IterableBase] using [method next].

## Returns next element in the iterable sequence. Return instance of 
## [ItEnd] when end is reached.
func next() -> Variant:
	NotImplementedError.raise()
	return null

## Return 'true' if the sequence has another element.
func has_next() -> bool:
	NotImplementedError.raise()
	return false

## Returns the first element within the sequence
func front() -> Variant:
	NotImplementedError.raise()
	return null

## Returns the last element within the sequence
func back() -> Variant:
	NotImplementedError.raise()
	return null

## Returns 'true' if the iterable sequence is empty.
func empty() -> bool:
	NotImplementedError.raise()
	return false

## Returns the n-th element within the sequence.
func at(_n : int) -> Variant:
	NotImplementedError.raise()
	return false
