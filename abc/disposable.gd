class_name DisposableBase

## Disposables represent Subscriptions in GDRx
##
## Whenever [method dispose] is called, the corresponding
## action is performed, e.g. to destroy and clean up a subscription.

## Disposes the disposable and executes a defined action.
func dispose():
	GDRx.exc.NotImplementedException.Throw()

## Links the disposable to a [Node]'s lifetime in the scene-tree.
## When [signal Node.tree_exiting] is emited by the [Node], the disposable is disposed.
func dispose_with(node : Node) -> DisposableBase:
	GDRx.exc.NotImplementedException.Throw()
	return null
