extends DisposableBase
class_name RefCountDisposable

class InnerDisposable extends DisposableBase:
	var parent : RefCountDisposable
	var is_disposed : bool
	var lock : RLock
	
	func _init(parent_ : RefCountDisposable):
		self.parent = parent_
		self.is_disposed = false
		self.lock = RLock.new()
	
	func dispose():
		self.lock.lock()
		var _parent = self.parent
		self.parent = null
		self.lock.unlock()
		
		if _parent != null:
			_parent.release()

var underlying_disposable : DisposableBase
var is_primary_disposed : bool
var is_disposed : bool
var lock : RLock
var count : int

func _init(disposable_ : DisposableBase):
	self.underlying_disposable = disposable_
	self.is_primary_disposed = false
	self.is_disposed = false
	self.lock = RLock.new()
	self.count = 0
	
	super._init()

func dispose():
	if self.is_disposed:
		return
	
	var _underlying_disposable = null
	self.lock.lock()
	if not self.is_primary_disposed:
		self.is_primary_disposed = true
		if not bool(self.count):
			self.is_disposed = true
			_underlying_disposable = self.underlying_disposable
	self.lock.unlock()
	
	if _underlying_disposable != null:
		_underlying_disposable.dispose()

func release():
	if self.is_disposed:
		return
	
	var should_dispose = false
	self.lock.lock()
	self.count -= 1
	if not bool(self.count) and self.is_primary_disposed:
		self.is_disposed = true
		should_dispose = true
	self.lock.unlock()
	
	if should_dispose:
		self.underlying_disposable.dispose()

func get_disposable() -> DisposableBase:
	self.lock.lock()
	if self.is_disposed:
		self.lock.unlock()
		return Disposable.new()
	
	self.count += 1
	var disp = InnerDisposable.new(self)
	self.lock.unlock()
	return disp

var disposable : DisposableBase: 
	get: return get_disposable()

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(obj : Object) -> DisposableBase:
	AutoDisposer.Add(obj, self)
	return self
