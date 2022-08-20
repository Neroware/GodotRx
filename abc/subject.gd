class_name SubjectBase

## Interface of a Subject.
##
## A subject is both an [Observer] and [Observable] in RxPY, 
## meaning it implements both interfaces, however, in GDScript, this is not 
## allowed! So, access to its two behaviors is given via [code]observer()[/code]
## and [code]observable()[/code] in GDRx.

## Returns the Subject's [Observer] behavior.
func observer() -> ObserverBase:
	push_error("No implementation here!")
	return null

## Returns the Subject's [Observable] behavior.
func observable() -> ObservableBase:
	push_error("No implementation here!")
	return null
