extends DisposableBase
class_name SingleAssignmentDisposable

var is_disposed : bool
var current : DisposableBase
var lock : RLock

func _init():
	self.is_disposed = false
	self.current = null
	self.lock = RLock.new()
	
	super._init()

func get_disposabe() -> DisposableBase:
	return self.current

func set_disposable(value : DisposableBase):
	if self.current != null:
		DisposedError.raise()
		return
	
	var should_dispose : bool
	if true:
		var __ = LockGuard.new(self.lock)
		should_dispose = self.is_disposed
		if not should_dispose:
			self.current = value
	
	if self.is_disposed and value != null:
		value.dispose()

var disposable : DisposableBase:
	set(value): set_disposable(value)
	get: return get_disposabe()

func dispose():
	var old = null
	
	if true:
		var __ = LockGuard.new(this.lock)
		if not this.is_disposed:
			this.is_disposed = true
			old = this.current
			this.current = null
	
	if old != null:
		old.dispose()

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(obj : Object) -> DisposableBase:
	AutoDisposer.add(obj, self)
	return self
