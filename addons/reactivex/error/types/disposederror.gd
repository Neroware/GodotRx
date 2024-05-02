extends RxBaseError
class_name DisposedError

const ERROR_TYPE = "DisposedError"
const ERROR_MESSAGE = "The requested element was disposed before"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(DisposedError.new(msg), default)
