extends RxBaseError
class_name BadMappingError

const ERROR_TYPE = "BadMappingError"

func _init(msg : String = "A mapping did not succeed"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "A mapping did not succeed", default = null):
	return GDRx.raise(BadMappingError.new(msg), default)
