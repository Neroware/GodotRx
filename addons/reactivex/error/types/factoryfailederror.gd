extends RxBaseError
class_name FactoryFailedError

const ERROR_TYPE = "FactoryFailedError"
const ERROR_MESSAGE = "A factory failed"

var _produced : Variant

func _init(produced_ : Variant, msg_ : String = ERROR_MESSAGE):
	self._produced = produced_
	var msg : String = msg_ + ":!" + str(self._produced)
	super._init(msg, ERROR_TYPE)

func get_produced_item() -> Variant:
	return self._produced

static func raise(default = null, msg : String = ERROR_MESSAGE, produced = null):
	return GDRx.raise(FactoryFailedError.new(produced, msg), default)
