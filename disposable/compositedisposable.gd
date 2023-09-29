extends DisposableBase
class_name CompositeDisposable

## A collection of disposables
## 
## When disposed, the underlying composition of disposables are disposed as well.

var disposable : Array
var is_disposed : bool
var lock : RLock


func _init(sources_ = []):
	var sources = GDRx.iter(sources_)
	while sources.has_next():
		self.disposable.push_back(sources.next())
	
	self.is_disposed = false
	self.lock = RLock.new()
	super._init()

func add(item : DisposableBase):
	var should_dispose = false
	if true:
		var __ = LockGuard.new(self.lock)
		if self.is_disposed:
			should_dispose = true
		else:
			self.disposable.append(item)
	
	if should_dispose:
		item.dispose()

func remove(item : DisposableBase) -> bool:
	if self.is_disposed:
		return false
	
	var should_dispose = false
	if true:
		var __ = LockGuard.new(self.lock)
		if item in self.disposable:
			self.disposable.erase(item)
			should_dispose = true
	
	if should_dispose:
		item.dispose()
	
	return should_dispose

func dispose():
	if this.is_disposed:
		return
	
	var current_disposable
	if true:
		var __ = LockGuard.new(this.lock)
		this.is_disposed = true
		current_disposable = this.disposable
		this.disposable = []
	
	for disp in current_disposable:
		disp.dispose()

func clear():
	var current_disposable
	if true:
		var __ = LockGuard.new(self.lock)
		current_disposable = self.disposable
		self.disposable = []
	
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
	AutoDisposer.add(obj, self)
	return self
