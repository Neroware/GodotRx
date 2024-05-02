extends RxBaseError
class_name DividedByZeroError

const ERROR_TYPE = "DividedByZeroError"
const ERROR_MESSAGE = "Divided by zero"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(DividedByZeroError.new(msg), default)
