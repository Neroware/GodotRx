extends RxBaseError
class_name NullReferenceError

const ERROR_TYPE = "NullReferenceError"
const ERROR_MESSAGE = "Instance not set to a value"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(NullReferenceError.new(msg), default)
