@tool
class_name IterableBase

## An iterable type
## 
## An [IterableBase] constructs an [IteratorBase] to iterate over it.
## This is done using the [method iter] method.

var __it__ : Iterator
var __curr__ : Variant

## Returns an iterator onto the given iterable sequence.
func iter() -> Iterator:
	NotImplementedError.raise()
	return null

func _iter_init(arg):
	self.__it__ = iter()
	var continue_ = self.__it__.has_next()
	self.__curr__ = self.__it__.next()
	return continue_

func _iter_next(arg):
	var continue_ = self.__it__.has_next()
	self.__curr__ = self.__it__.next()
	return continue_

func _iter_get(arg):
	return self.__curr__
