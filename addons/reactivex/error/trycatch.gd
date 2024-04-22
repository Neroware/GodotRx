class_name TryCatch

var _risky_code : Callable
var _caught_types : Dictionary

var caught_types : Dictionary:
	get: return self._caught_types.duplicate()
var risky_code : Callable:
	get: return self._risky_code

func _init(fun : Callable = GDRx.basic.noop):
	self._risky_code = fun
	self._caught_types = {}

func end_try_catch() -> bool:
	return ErrorHandler.singleton().run(self)

func catch(type : String, fun : Callable = GDRx.basic.noop) -> TryCatch:
	if self._caught_types.has(type):
		return
	self._caught_types[type] = fun
	return self

func catch_all(types : Array[String], fun : Callable = GDRx.basic.noop) -> TryCatch:
	for type in types:
		if self._caught_types.has(type):
			continue
		self._caught_types[type] = fun
	return self
