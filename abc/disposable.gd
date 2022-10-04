class_name DisposableBase

## Disposables represent Subscriptions in GDRx
##
## Whenever [method dispose] is called, the corresponding
## action is performed, e.g. to destroy and clean up a subscription.

## Disposes the disposable and executes a defined action.
func dispose():
	GDRx.exc.NotImplementedException.Throw()

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(obj : Object) -> DisposableBase:
	GDRx.exc.NotImplementedException.Throw()
	return null
