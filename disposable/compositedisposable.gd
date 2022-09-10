extends DisposableBase
class_name CompositeDisposable

## A collection of disposables
##
## When disposed, the underlying composition of disposables are disposed as well.

var _disposable : Array
var _is_disposed : bool
var _lock : RLock


func _init(args = []):
	if args is Array:
		self._disposable = args
	else:
		self._disposable = [args]
	
	self._is_disposed = false
	self._lock = RLock.new()

func add(item : DisposableBase):
	var should_dispose = false
	self._lock.lock()
	if self._is_disposed:
		should_dispose = true
	else:
		self._disposable.append(item)
	self._lock.unlock()
	
	if should_dispose:
		item.dispose()

func remove(item : DisposableBase) -> bool:
	if self._is_disposed:
		return false
	
	var should_dispose = false
	self._lock.lock()
	if item in self._disposable:
		self._disposable.erase(item)
		should_dispose = true
	self._lock.unlock()
	
	if should_dispose:
		item.dispose()
	
	return should_dispose

func dispose():
	if self._is_disposed:
		return
	
	self._lock.lock()
	self._is_disposed = true
	var current_disposable = self._disposable
	self._disposable = []
	self._lock.unlock()
	
	for disp in current_disposable:
		disp.dispose()

func clear():
	self._lock.lock()
	var current_disposable = self._disposable
	self._disposable = []
	self._lock.unlock()
	
	for disposable in current_disposable:
		disposable.dispose()

func contains(item : DisposableBase) -> bool:
	return item in self._disposable

func to_list() -> Array[DisposableBase]:
	return self._disposable

func length() -> int:
	return self._disposable.size()
