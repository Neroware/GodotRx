extends RxBaseError
class_name AssertionFailedError

const ERROR_TYPE = "AssertionFailedError"
const ERROR_MESSAGE = "Assertion failed"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(AssertionFailedError.new(msg), default)
