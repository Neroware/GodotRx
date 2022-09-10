extends DisposableBase
class_name Disposable
## Main disposable class
##
## Invokes specified action when disposed.

var _is_disposed : bool
var _action : Callable
var _lock : RLock

var _dispose_with : Dictionary

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
func _init(action : Callable = func(): return):
	self._is_disposed = false
	self._action = action
	self._lock = RLock.new()

## Performs the task of cleaning up resources.
func dispose():
	var dispose = false
	self._lock.lock()
	if not self._is_disposed:
		dispose = true
		self._is_disposed = true
	self._lock.unlock()
	
	if dispose:
		self._action.call()

## Links disposable to [Node] lifetime in scene-tree via [signal Node.tree_exiting].
func dispose_with(node : Node) -> DisposableBase:
	_lock.lock()
	_dispose_with[node] = func():
		self.dispose()
		node.disconnect("tree_exiting", _dispose_with[node])
	_lock.unlock()
	
	node.connect("tree_exiting", _dispose_with[node])
	return self

## Casts any object with [code]dispose()[/code] to a [DisposableBase].
static func Cast(obj) -> DisposableBase:
	if obj.has_method("dispose"):
		return Disposable.new(obj.dispose)
	return Disposable.new()
