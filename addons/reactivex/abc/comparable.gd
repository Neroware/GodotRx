class_name Comparable

## Interface for comparable objects
## 
## This interface provides comparison functions. It is needed because GDScript
## does not allow defining custom operators.

func eq(_other) -> bool:
	NotImplementedError.raise()
	return false

func lt(_other) -> bool:
	NotImplementedError.raise()
	return false

func gt(_other) -> bool:
	NotImplementedError.raise()
	return false

func gte(other) -> bool:
	return eq(other) or gt(other)

func lte(other) -> bool:
	return eq(other) or lt(other)

func neq(other) -> bool:
	return not eq(other)
