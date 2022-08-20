class_name ObserverBase

## Interface of an observer
##
## All communication in GDRx is handled asynchronously via observable data 
## streams, so-called [Observable]s. An [Observer] can subscribe to an 
## [Observable] to receive emitted items sent on the stream.
## Create a new subscription via [code]subscribe(...)[/code].
## An [Observer] needs to abide by the Observer-Observable-Contract as defined
## in this interface.
##
## Notifications are [code]on_next(i)[/code], [code]on_error(e)[/code] and
## [code]on_completed()[/code].

## Called when the [Observable] emits a new item on the stream
func on_next(i):
	push_error("No implementation here!")

## Called when the [Observable] emits an error on the stream
func on_error(e):
	push_error("No implementation here!")

## Called when the [Observable] is finished and no more items are sent.
func on_completed():
	push_error("No implementation here!")
