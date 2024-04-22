extends RxBaseError
class_name FactoryFailedError

const ERROR_TYPE = "FactoryFailedError"

var _produced : Variant

func _init(produced : Variant, msg : String = "Factory failed:!\"" + str(produced) + "\""):
	self._produced = produced
	super._init(msg, ERROR_TYPE)

func get_produced_item() -> Variant:
	return self._produced

static func raise(msg : String = "Factory failed", default = null, produced = null):
	return GDRx.raise(FactoryFailedError.new(produced, msg + ":!\"" + str(produced) + "\""), default)
