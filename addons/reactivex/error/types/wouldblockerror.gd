extends RxBaseError
class_name WouldBlockError

const ERROR_TYPE = "WouldBlockError"
const ERROR_MESSAGE = "Would block thread"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(WouldBlockError.new(msg), default)
