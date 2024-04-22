extends RxBaseError
class_name AssertionFailedError

const ERROR_TYPE = "AssertionFailedError"

func _init(msg : String = "Assertion failed"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "Assertion failed", default = null):
	return GDRx.raise(AssertionFailedError.new(msg), default)
