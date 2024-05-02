extends RxBaseError
class_name NotImplementedError

const ERROR_TYPE = "NotImplementedError"
const ERROR_MESSAGE = "There is no implementation"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(NotImplementedError.new(msg), default)
