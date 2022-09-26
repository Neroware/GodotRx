extends DisposableBase
class_name RefCountDisposable

class InnerDisposable extends DisposableBase:
	var parent : RefCountDisposable
	var is_disposed : bool
	var lock : RLock
	
	func _init(parent : RefCountDisposable):
		self.parent = parent
		self.is_disposed = false
		self.lock = RLock.new()
	
	func dispose():
		self.lock.lock()
		var parent = self.parent
		self.parent = null
		self.lock.unlock()
		
		if parent != null:
			parent.release()

var underlying_disposable : DisposableBase
var is_primary_disposed : bool
var is_disposed : bool
var lock : RLock
var count : int

func _init(disposable : DisposableBase):
	self.underlying_disposable = disposable
	self.is_primary_disposed = false
	self.is_disposed = false
	self.lock = RLock.new()
	self.count = 0
	
	super._init()

func dispose():
	if self.is_disposed:
		return
	
	var underlying_disposable = null
	self.lock.lock()
	if not self.is_primary_disposed:
		self.is_primary_disposed = true
		if not bool(self.count):
			self.is_disposed = true
			underlying_disposable = self.underlying_disposable
	self.lock.unlock()
	
	if underlying_disposable != null:
		underlying_disposable.dispose()

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
