class_name SubjectBase

## Interface of a Subject.
##
## A subject is both an [Observer] and [Observable] in RxPY, 
## meaning it implements both interfaces, however, in GDScript, this is not 
## allowed! So, access to its two behaviors is given via [method as_observer]
## and [method as_observable] in GDRx.

## Returns the Subject's [Observer] behavior.
func as_observer() -> ObserverBase:
	GDRx.exc.NotImplementedException.Throw()
	return null

## Returns the Subject's [Observable] behavior.
func as_observable() -> ObservableBase:
	GDRx.exc.NotImplementedException.Throw()
	return null

## The Subject's [Observer] behavior.
var obv : ObserverBase:
	get: return as_observer()

## The Subject's [Observable] behavior.
var obs : ObservableBase:
	get: return as_observable()
