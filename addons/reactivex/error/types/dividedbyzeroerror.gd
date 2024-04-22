extends RxBaseError
class_name DividedByZeroError

const ERROR_TYPE = "DividedByZeroError"

func _init(msg : String = "Divided by zero"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "Divided by zero", default = null):
	return GDRx.raise(DividedByZeroError.new(msg), default)
