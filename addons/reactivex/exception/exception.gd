## GDRx Exception types

func raise(msg : String, default = null):
	return GDRx.raise(self.Exception.new(msg), default)

class Exception extends ThrowableBase:
	var _msg : String
	func _init(msg : String):
		self._msg = msg
	
	func _to_string() -> String:
		return "[" + self.tags().back() + "::" + _msg + "]"
	
	func throw(default = null) -> Variant:
		return ExceptionHandler.singleton().raise(self, default)
	
	func tags() -> Array[String]:
		return ["Exception"]
	
	static func Throw(default = null) -> Variant:
		return Exception.new("An exception occured!").throw(default)

class NotImplementedException extends Exception:
	func _init():
		super._init("There is no implementation!")
	
	func tags() -> Array[String]:
		return ["Exception", "NotImplementedException"]
	
	static func Throw(default = null) -> Variant:
		return NotImplementedException.new().throw(default)

class DivideByZeroException extends Exception:
	func _init():
		super._init("Divided by zero!")
	
	func tags() -> Array[String]:
		return ["Exception", "DivideByZeroException"]
	
	static func Throw(default = null) -> Variant:
		return DivideByZeroException.new().throw(default)

class WouldBlockException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Would block!")
	
	func tags() -> Array[String]:
		return ["Exception", "WouldBlockException"]
	
	static func Throw(default = null) -> Variant:
		return WouldBlockException.new().throw(default)

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
	
	static func Throw(default = null) -> Variant:
		return FactoryFailedException.new().throw(default)

class BadMappingException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("A mapping did not succeed!")
	
	func tags() -> Array[String]:
		return ["Exception", "BadMappingException"]
	
	static func Throw(default = null) -> Variant:
		return BadMappingException.new().throw(default)

class BadPredicateError extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("A predicate failed!")
	
	func tags() -> Array[String]:
		return ["Exception", "BadPredicateError"]
	
	static func Throw(default = null) -> Variant:
		return BadPredicateError.new().throw(default)

class SequenceContainsNoElementsException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("The given sequence is empty!")
	
	func tags() -> Array[String]:
		return ["Exception", "SequenceContainsNoElementsException"]
	
	static func Throw(default = null) -> Variant:
		return SequenceContainsNoElementsException.new().throw(default)

class DisposedException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("The requested element was disposed!")
	
	func tags() -> Array[String]:
		return ["Exception", "DisposedException"]
	
	static func Throw(default = null) -> Variant:
		return DisposedException.new().throw(default)

class ArgumentOutOfRangeException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Argument out of range!")
	
	func tags() -> Array[String]:
		return ["Exception", "ArgumentOutOfRangeException"]
	
	static func Throw(default = null) -> Variant:
		return ArgumentOutOfRangeException.new().throw(default)

class TooManyArgumentsException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Too many arguments for given function!")
	
	func tags() -> Array[String]:
		return ["Exception", "TooManyArgumentsException"]
	
	static func Throw(default = null) -> Variant:
		return TooManyArgumentsException.new().throw(default)

class LockNotAquiredException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Lock has not been aquired!")
	
	func tags() -> Array[String]:
		return ["Exception", "LockNotAquiredException"]
	
	static func Throw(default = null) -> Variant:
		return LockNotAquiredException.new().throw(default)

class NullReferenceException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Instance not set to a value!")
	
	func tags() -> Array[String]:
		return ["Exception", "NullReferenceException"]
	
	static func Throw(default = null) -> Variant:
		return NullReferenceException.new().throw(default)

class BadArgumentException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("An argument contained bad input!")
	
	func tags() -> Array[String]:
		return ["Exception", "BadArgumentException"]
	
	static func Throw(default = null) -> Variant:
		return BadArgumentException.new().throw(default)

class AssertionFailedException extends Exception:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Assertion failed!")
	
	func tags() -> Array[String]:
		return ["Exception", "AssertionFailedException"]
	
	static func Throw(default = null) -> Variant:
		return AssertionFailedException.new().throw(default)

class TypeMismatchException extends Exception:
	func _init(item):
		var msg : String = "Type mismatch in observable sequence! Got '" + \
			str(item) + \
			"' which is of wrong type!"
		super._init(msg)
	
	func tags() -> Array[String]:
		return ["Exception", "TypeMismatchException"]
	
	static func Throw(item = null) -> Variant:
		return TypeMismatchException.new(item).throw(null)

class HttpRequestFailedException extends Exception:
	var url : String
	var error_code : int
	var error_message : String
	
	func _init(url_ : String, error_code_ : int, error_message_ : String):
		self.url = url_
		self.error_code = error_code_
		self.error_message = error_message_
		var msg = "HTTP Request to host '" + url + "' failed! " \
			+ "(" + error_message + ")"
		super._init(msg)
	
	func tags() -> Array[String]:
		return ["Exception", "HttpRequestFailedException"]
	
	static func Throw(_item = null) -> Variant:
		return NotImplementedException.Throw()
