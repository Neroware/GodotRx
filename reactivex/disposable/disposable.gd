extends DisposableBase
class_name Disposable

var _is_disposed : bool
var _action : Callable
var _lock : RLock

var _dispose_with : Dictionary

func _init(action : Callable = func(): return):
	self._is_disposed = false
	self._action = action
	self._lock = RLock.new()

func dispose():
	var dispose = false
	self._lock.lock()
	if not self._is_disposed:
		dispose = true
		self._is_disposed = true
	self._lock.unlock()
	
	if dispose:
		self._action.call()

func dispose_with(node : Node) -> DisposableBase:
	_lock.lock()
	_dispose_with[node] = func():
		self.dispose()
		node.disconnect("tree_exiting", _dispose_with[node])
	_lock.unlock()
	
	node.connect("tree_exiting", _dispose_with[node])
	return self
