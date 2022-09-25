class_name SubjectBase

## Interface of a Subject.
##
## A subject is both an [Observer] and [Observable] in RxPY, 
## meaning it implements both interfaces, however, in GDScript, this is not 
## allowed! So, access to its two behaviors is given via [method as_observer]
## and [method as_observable] in GDRx.

## Returns the Subject's [Observer] behavior.
func as_observer() -> ObserverBase:
	GDRx.raise(GDRx.exc.NotImplementedException.new())
	return null

## Returns the Subject's [Observable] behavior.
func as_observable() -> ObservableBase:
	GDRx.raise(GDRx.exc.NotImplementedException.new())
	return null
