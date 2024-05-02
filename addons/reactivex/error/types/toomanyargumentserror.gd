extends RxBaseError
class_name TooManyArgumentsError

const ERROR_TYPE = "TooManyArgumentsError"
const ERROR_MESSAGE = "Too many arguments for given function"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(TooManyArgumentsError.new(msg), default)
