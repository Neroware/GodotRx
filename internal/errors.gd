## GDRx Error types

class Error:
	var _msg : String
	func _init(msg : String):
		self._msg = msg
	
	func _to_string() -> String:
		return "[GDRX Error::" + _msg + "]"

class WouldBlockException extends Error:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Would block")

class FactoryFailedException extends Error:
	var _produced
	
	func _init(msg = null, produced = null):
		self._produced = produced
		if msg != null: super._init(str(msg))
		else: super._init("Factory failed and produced: " + str(self._produced))
	
	func get_produced_object():
		return self._produced

class BadMappingException extends Error:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("A mapping did not succeed!")

class BadPredicateError extends Error:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("A predicate failed!")

class SequenceContainsNoElementsException extends Error:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("The given sequence is empty!")

class DisposedException extends Error:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("The requested element was disposed!")

class ArgumentOutOfRangeException extends Error:
	func _init(msg = null):
		if msg != null: super._init(str(msg))
		else: super._init("Argument out of range!")
