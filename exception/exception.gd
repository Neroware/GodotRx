## GDRx Exception types

func raise(msg : String, default = null):
	return GDRx.raise(self.Exception.new(msg), default)

class Exception extends ThrowableBase:
	var _msg : String
	func _init(msg : String):
		self._msg = msg
	
	func _to_string() -> String:
		return "[GDRx Exception::" + _msg + "]"
	
	func throw(default = null) -> Variant:
		return ExceptionHandler.singleton().raise(self, default)
	
	func tags() -> Array[String]:
		return ["Exception"]

class NotImplementedException extends Exception:
	func _init():
		super._init("There is no implementation!")
	
	func tags() -> Array[String]:
		return ["Exception", "NotImplementedException"]

class DivideByZeroException extends Exception:
	func _init():
		super._init("Divided by zero!")
	
	func tags() -> Array[String]:
		return ["Exception", "DivideByZeroException"]

class WouldBlockException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Would block!")
	
	func tags() -> Array[String]:
		return ["Exception", "WouldBlockException"]

class FactoryFailedException extends Exception:
	var _produced
	
	func _init(msg = null, produced = null):
		self._produced = produced
		if msg != null: super._init(str(msg))
		else: super._init("Factory failed and produced: " + str(self._produced))
	
	func get_produced_object():
		return self._produced
	
	func tags() -> Array[String]:
		return ["Exception", "FactoryFailedException"]

class BadMappingException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("A mapping did not succeed!")
	
	func tags() -> Array[String]:
		return ["Exception", "BadMappingException"]

class BadPredicateError extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("A predicate failed!")
	
	func tags() -> Array[String]:
		return ["Exception", "BadPredicateError"]

class SequenceContainsNoElementsException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("The given sequence is empty!")
	
	func tags() -> Array[String]:
		return ["Exception", "SequenceContainsNoElementsException"]

class DisposedException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("The requested element was disposed!")
	
	func tags() -> Array[String]:
		return ["Exception", "DisposedException"]

class ArgumentOutOfRangeException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Argument out of range!")
	
	func tags() -> Array[String]:
		return ["Exception", "ArgumentOutOfRangeException"]

class TooManyArgumentsException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Too many arguments for given function!")
	
	func tags() -> Array[String]:
		return ["Exception", "TooManyArgumentsException"]

class LockNotAquiredException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Lock has not been aquired!")
	
	func tags() -> Array[String]:
		return ["Exception", "LockNotAquiredException"]

class NullReferenceException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Instance not set to a value!")
	
	func tags() -> Array[String]:
		return ["Exception", "NullReferenceException"]

class BadArgumentException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("An argument contained bad input!")
	
	func tags() -> Array[String]:
		return ["Exception", "BadArgumentException"]
