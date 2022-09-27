class_name ExceptionHandler

## Handles raised Exceptions
##
## Objects of type [ThrowableBase] are handled by this type's singleton

var _try_catch_stack : Array[TryCatch]

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")
	self._try_catch_stack = []

static func singleton() -> ExceptionHandler:
	return GDRx.ExceptionHandler_

func add(stmt : TryCatch):
	self._try_catch_stack.push_back(stmt)
	stmt.risky_code.call()
	self._try_catch_stack.pop_back()

func raise(exc : ThrowableBase, default = null) -> Variant:
	var handler : Callable = GDRx.basic.default_crash
	
	if self._try_catch_stack.is_empty():
		handler.call(exc)
		return default
	
	handler = GDRx.basic.noop
	
	var stmt : TryCatch = self._try_catch_stack.pop_back()
	for type in stmt.caught_types.keys():
		if type in exc.tags():
			handler = stmt.caught_types[type]
			break
	
	handler.call(exc)
	return default
