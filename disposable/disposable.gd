extends DisposableBase
class_name Disposable
## Main disposable class
##
## Invokes specified action when disposed.

var is_disposed : bool
var action : Callable

var lock : RLock

## Creates a disposable object that invokes the specified
##        action when disposed.
## [br]
##        [b]Args:[/b]
## [br]
##            [code]action[/code] Action to run during the first call to dispose.
##                The action is guaranteed to be run at most once.
## [br][br]
##        [b]Returns:[/b]
## [br]
##            The disposable object that runs the given action upon
##            disposal.
func _init(action_ : Callable = func(): return):
	self.is_disposed = false
	self.action = action_
	self.lock = RLock.new()
	
	super._init()

## Performs the task of cleaning up resources.
func dispose():
	var disposed = false
	self.lock.lock()
	if not self.is_disposed:
		disposed = true
		self.is_disposed = true
	self.lock.unlock()
	
	if disposed:
		self.action.call()

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(obj : Object) -> DisposableBase:
	AutoDisposer.Add(obj, self)
	return self

## Casts any object with [code]dispose()[/code] to a [DisposableBase].
static func Cast(obj) -> DisposableBase:
	if obj.has_method("dispose"):
		return Disposable.new(obj.dispose)
	return Disposable.new()
