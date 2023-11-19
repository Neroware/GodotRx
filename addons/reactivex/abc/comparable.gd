class_name Comparable

## Interface for comparable objects
## 
## This interface provides comparison functions. It is needed because GDScript
## does not allow defining custom operators.

func eq(_other) -> bool:
	GDRx.exc.NotImplementedException.Throw()
	return false

func lt(_other) -> bool:
	GDRx.exc.NotImplementedException.Throw()
	return false

func gt(_other) -> bool:
	GDRx.exc.NotImplementedException.Throw()
	return false

func gte(other) -> bool:
	return eq(other) or gt(other)

func lte(other) -> bool:
	return eq(other) or lt(other)

func neq(other) -> bool:
	return not eq(other)
