extends DisposableBase
class_name SerialDisposable

var current : DisposableBase
var is_disposed : bool
var lock : RLock

func _init():
	self.current = null
	self.is_disposed = false
	self.lock = RLock.new()
	
	super._init()

func get_disposable() -> DisposableBase:
	return self.current

func set_disposable(value : DisposableBase):
	var old = null
	
	self.lock.lock()
	var should_dispose = self.is_disposed
	if not should_dispose:
		old = self.current
		self.current = value
	self.lock.unlock()
	
	if old != null:
		old.dispose()
	
	if should_dispose and value != null:
		value.dispose()

var disposable : DisposableBase:
	get: return get_disposable()
	set(value): set_disposable(value)

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
	
