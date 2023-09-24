class_name DisposableBase

## Disposables represent Subscriptions in GDRx
##
## Whenever [method dispose] is called, the corresponding
## action is performed, e.g. to destroy and clean up a subscription.

## This is the [b]this[/b] reference. It acts like std::enable_shared_from_this
## and is ignored in ref-counting. Yes, I do know what I am doing! 
## I coded this in C++!
var this : DisposableBase

func _init():
	this = self
	this.unreference()

## Disposes the disposable and executes a defined action.
func dispose():
	print("DISPOSE: ", this)
	# GDRx.exc.NotImplementedException.Throw()

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(_obj : Object) -> DisposableBase:
	GDRx.exc.NotImplementedException.Throw()
	return null

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()
