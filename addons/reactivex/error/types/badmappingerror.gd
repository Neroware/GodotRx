extends RxBaseError
class_name BadMappingError

const ERROR_TYPE = "BadMappingError"
const ERROR_MESSAGE = "A mapping did not succeed"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(BadMappingError.new(msg), default)
