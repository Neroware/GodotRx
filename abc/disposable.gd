class_name DisposableBase

## Disposables represent Subscriptions in GDRx
##
## Whenever a Disposable's [code]dispose()[/code] is called, the corresponding
## action is performed to destroy and clean up the subscription.

## Disposes the disposable and executes a defined action.
func dispose():
	push_error("No implementation here!")

## Links the disposable to a [Node]'s lifetime in the scene-tree.
## When [code]tree_exiting[/code] is emited by the [Node], the disposable is disposed.
func dispose_with(node : Node) -> DisposableBase:
	push_error("No implementation here!")
	return null
