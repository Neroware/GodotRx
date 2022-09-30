class_name ExceptionHandler

## Handles raised Exceptions
##
## Objects of type [ThrowableBase] are handled by this type's singleton

var _try_catch_stack : WeakKeyDictionary # WeakKeyDictionary{Thread -> Array[TryCatch]}
var _has_failed : Dictionary
var _lock : RLock

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")
	self._try_catch_stack = WeakKeyDictionary.new()
	self._has_failed = {}
	self._lock = RLock.new()

static func singleton() -> ExceptionHandler:
	return GDRx.ExceptionHandler_

func run(stmt : TryCatch) -> bool:
	var thread = GDRx.get_current_thread()
	
	self._lock.lock()
	self._has_failed[stmt] = false
	if not self._try_catch_stack.has_key(thread):
		self._try_catch_stack.set_pair(thread, [stmt])
	else:
		self._try_catch_stack.get_value(thread).push_back(stmt)
	self._lock.unlock()
	
	stmt.risky_code.call()
	
	self._lock.lock()
	self._try_catch_stack.get_value(thread).pop_back()
	var failed = self._has_failed[stmt]
	self._has_failed.erase(stmt)
	self._lock.unlock()
	
	return failed

func raise(exc : ThrowableBase, default = null) -> Variant:
	var handler : Callable = GDRx.basic.default_crash
	var thread = GDRx.get_current_thread()
	
	var current_thread_stack = self._try_catch_stack.get_value(thread)
	if current_thread_stack == null or current_thread_stack.is_empty():
		handler.call(exc)
		return default
	
	handler = GDRx.basic.noop
	
	var stmt : TryCatch = current_thread_stack.pop_back()
	self._has_failed[stmt] = true
	for type in exc.tags():
		if type in stmt.caught_types:
			handler = stmt.caught_types[type]
			break
	
	handler.call(exc)
	current_thread_stack.push_back(stmt)
	return default
