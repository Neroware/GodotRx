class_name ExceptionHandler

## Handles raised Exceptions
##
## Objects of type [ThrowableBase] are handled by this type's singleton

var _try_catch_stack : Array[TryCatch]
var _raised_exceptions : Dictionary

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")
	self._try_catch_stack = []
	self._raised_exceptions = {}

static func singleton() -> ExceptionHandler:
	return GDRx.ExceptionHandler_

func run(stmt : TryCatch):
	var failed_ = false
	self._raised_exceptions[stmt] = []
	self._try_catch_stack.push_front(stmt)
	
	stmt.risky_code.call()
	if self._raised_exceptions[stmt].size() > 0:
		failed_ = true
		_handle_exceptions()
	
	self._try_catch_stack.pop_front()
	self._raised_exceptions.erase(stmt)
	return failed_

func raise(exc : ThrowableBase, default = null) -> Variant:
	if self._try_catch_stack.is_empty():
		GDRx.basic.default_crash.call(exc)
	var current : TryCatch = self._try_catch_stack[0]
	self._raised_exceptions[current].append(exc)
	
	return default

func _handle_exceptions():
	var stmt : TryCatch = self._try_catch_stack.pop_front()
	var handler : Callable = GDRx.basic.noop
	
	if self._raised_exceptions[stmt].size() > 1:
		push_warning("Risky code produced more than one exception! Only first one is handled!")
	var exc = self._raised_exceptions[stmt][0]
	
	for type in exc.tags():
		if type in stmt.caught_types.keys():
			handler = stmt.caught_types[type]
	
	handler.call(exc)
	self._try_catch_stack.push_front(stmt)
