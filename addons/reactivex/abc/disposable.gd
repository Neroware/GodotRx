class_name DisposableBase

## Disposables represent Subscriptions in GDRx
## [br][br]
## Whenever [method dispose] is called, the corresponding
## action is performed, e.g. to destroy and clean up a subscription.

## This is the [b]this[/b] reference. It acts like 
## [code]std::enable_shared_from_this<>[/code] and is ignored in ref-counting. 
## Yes, I do know what I am doing! I coded something similar in C++!
var this

func _init():
	this = self
	this.unreference()

## Disposes the disposable and executes a defined action.
func dispose():
	NotImplementedError.raise()

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(_obj : Object) -> DisposableBase:
	NotImplementedError.raise()
	return null

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()
