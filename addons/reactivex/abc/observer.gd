class_name ObserverBase

## Interface of an observer
## 
## All communication in GDRx is handled asynchronously via observable data 
## streams, so-called [Observable]s. An [Observer] can subscribe to an 
## [Observable] to receive emitted items sent on the stream.
## Create a new subscription via [method ObservableBase.subscribe].
## An [Observer] needs to abide by the Observer-Observable-Contract as defined
## in this interface.
##
## Notifications are [method on_next], [method on_error] and
## [method on_completed].

## Called when the [Observable] emits a new item on the stream
func on_next(_i):
	NotImplementedError.raise()

## Called when the [Observable] emits an error on the stream
func on_error(_e):
	NotImplementedError.raise()

## Called when the [Observable] is finished and no more items are sent.
func on_completed():
	NotImplementedError.raise()
