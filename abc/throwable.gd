class_name ThrowableBase

## Interface for throwable objects
##
## Objects that implement this interface can be used within a try-catch-
## structure.

func throw(_default = null) -> Variant:
	GDRx.exc.NotImplementedException.Throw()
	return null

func tags() -> Array[String]:
	GDRx.exc.NotImplementedException.Throw()
	return []
