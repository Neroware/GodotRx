class_name ThrowableBase

## Interface for throwable objects
## 
## Objects that implement this interface can be used within a try-catch-
## structure.

func throw(_default = null) -> Variant:
	NotImplementedError.raise()
	return null

func tags() -> Array[String]:
	NotImplementedError.raise()
	return []
