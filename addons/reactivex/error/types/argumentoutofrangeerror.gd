extends RxBaseError
class_name ArgumentOutOfRangeError

const ERROR_TYPE = "ArgumentOutOfRangeError"

func _init(msg : String = "Argument out of range"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "Argument out of range", default = null):
	return GDRx.raise(ArgumentOutOfRangeError.new(msg), default)
