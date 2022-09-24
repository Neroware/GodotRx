class_name ThrowableBase

## Interface for throwable objects
##
## Objects that implement this interface can be used within a try-catch-
## structure.

func throw(default = null) -> Variant:
	GDRx.raise(GDRx.exc.NotImplementedException.new())
	return null

func tags() -> Array[String]:
	GDRx.raise(GDRx.exc.NotImplementedException.new())
	return []
