extends RxBaseError
class_name LockNotAquiredError

const ERROR_TYPE = "LockNotAquiredError"

func _init(msg : String = "Lock has not been aquired"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "Lock has not been aquired", default = null):
	return GDRx.raise(LockNotAquiredError.new(msg), default)
