extends RxBaseError
class_name TooManyArgumentsError

const ERROR_TYPE = "TooManyArgumentsError"

func _init(msg : String = "Too many arguments for given function"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "Too many arguments for given function", default = null):
	return GDRx.raise(TooManyArgumentsError.new(msg), default)
