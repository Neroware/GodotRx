extends RxBaseError
class_name ArgumentOutOfRangeError

const ERROR_TYPE = "ArgumentOutOfRangeError"
const ERROR_MESSAGE = "Argument out of range"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(ArgumentOutOfRangeError.new(msg), default)
