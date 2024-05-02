extends RxBaseError
class_name BadArgumentError

const ERROR_TYPE = "BadArgumentError"
const ERROR_MESSAGE = "An argument contained bad input"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(BadArgumentError.new(msg), default)
