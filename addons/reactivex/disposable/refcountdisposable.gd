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
		super._init()
	
	func dispose():
		var _parent
		if true:
			var __ = LockGuard.new(this.lock)
			_parent = this.parent
			this.parent = null
		
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
	if this.is_disposed:
		return
	
	var _underlying_disposable = null
	if true:
		var __ = LockGuard.new(this.lock)
		if not this.is_primary_disposed:
			this.is_primary_disposed = true
			if not bool(this.count):
				this.is_disposed = true
				_underlying_disposable = this.underlying_disposable
	
	if _underlying_disposable != null:
		_underlying_disposable.dispose()

func release():
	if self.is_disposed:
		return
	
	var should_dispose = false
	if true:
		var __ = LockGuard.new(self.lock)
		self.count -= 1
		if not bool(self.count) and self.is_primary_disposed:
			self.is_disposed = true
			should_dispose = true
	
	if should_dispose:
		self.underlying_disposable.dispose()

func get_disposable() -> DisposableBase:
	var __ = LockGuard.new(self.lock)
	if self.is_disposed:
		return Disposable.new()
	
	self.count += 1
	return InnerDisposable.new(self)

var disposable : DisposableBase: 
	get: return get_disposable()

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(obj : Object) -> DisposableBase:
	AutoDisposer.add(obj, self)
	return self
