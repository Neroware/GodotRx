extends DisposableBase
class_name CompositeDisposable

## A collection of disposables
##
## When disposed, the underlying composition of disposables are disposed as well.

var disposable : Array
var is_disposed : bool
var lock : RLock


func _init(args = []):
	if args is Array:
		self.disposable = args
	else:
		self.disposable = [args]
	
	self.is_disposed = false
	self.lock = RLock.new()
	super._init()

func add(item : DisposableBase):
	var should_dispose = false
	self.lock.lock()
	if self.is_disposed:
		should_dispose = true
	else:
		self.disposable.append(item)
	self.lock.unlock()
	
	if should_dispose:
		item.dispose()

func remove(item : DisposableBase) -> bool:
	if self.is_disposed:
		return false
	
	var should_dispose = false
	self.lock.lock()
	if item in self.disposable:
		self.disposable.erase(item)
		should_dispose = true
	self.lock.unlock()
	
	if should_dispose:
		item.dispose()
	
	return should_dispose

func dispose():
	if self.is_disposed:
		return
	
	self.lock.lock()
	self.is_disposed = true
	var current_disposable = self.disposable
	self.disposable = []
	self.lock.unlock()
	
	for disp in current_disposable:
		disp.dispose()

func clear():
	self.lock.lock()
	var current_disposable = self.disposable
	self.disposable = []
	self.lock.unlock()
	
	for _disposable in current_disposable:
		_disposable.dispose()

func contains(item : DisposableBase) -> bool:
	return item in self.disposable

func to_list() -> Array[DisposableBase]:
	return self.disposable.duplicate()

func size() -> int:
	return self.disposable.size()

var length : int: get = size

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(obj : Object) -> DisposableBase:
	AutoDisposer.Add(obj, self)
	return self
