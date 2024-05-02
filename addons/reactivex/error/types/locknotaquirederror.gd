extends RxBaseError
class_name LockNotAquiredError

const ERROR_TYPE = "LockNotAquiredError"
const ERROR_MESSAGE = "Lock has not been aquired"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(LockNotAquiredError.new(msg), default)
