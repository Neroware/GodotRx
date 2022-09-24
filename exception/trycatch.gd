class_name TryCatch

var risky_code : Callable
var caught_types : Dictionary

func _init(fun : Callable = func():return):
	self.risky_code = fun
	self.caught_types = {}

func end_try_catch():
	ExceptionHandler.singleton().add(self)

func catch(type : String, fun : Callable = func(__):return) -> TryCatch:
	if type in self.caught_types.keys():
		return
	self.caught_types[type] = fun
	return self

func catch_all(types : Array[String], fun : Callable = func(__):return) -> TryCatch:
	for type in types:
		if type in self.caught_types.keys():
			continue
		self.caught_types[type] = fun
	return self
