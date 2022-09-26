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
		GDRx.exc.DisposedException.Throw()
		return
	
	self.lock.lock()
	var should_dispose = self.is_disposed
	if not should_dispose:
		self.current = value
	self.lock.unlock()
	
	if self.is_disposed and value != null:
		value.dispose()

var disposable : DisposableBase:
	set(value): set_disposable(value)
	get: return get_disposabe()

func dispose():
	var old = null
	
	self.lock.lock()
	if not self.is_disposed:
		self.is_disposed = true
		old = self.current
		self.current = null
	self.lock.unlock()
	
	if old != null:
		old.dispose()
