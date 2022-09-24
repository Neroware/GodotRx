class_name SubjectBase

## Interface of a Subject.
##
## A subject is both an [Observer] and [Observable] in RxPY, 
## meaning it implements both interfaces, however, in GDScript, this is not 
## allowed! So, access to its two behaviors is given via [method observer]
## and [method observable] in GDRx.

## Returns the Subject's [Observer] behavior.
func observer() -> ObserverBase:
	GDRx.raise(GDRx.exc.NotImplementedException.new())
	return null

## Returns the Subject's [Observable] behavior.
func observable() -> ObservableBase:
	GDRx.raise(GDRx.exc.NotImplementedException.new())
	return null
