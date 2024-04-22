extends RxBaseError
class_name WouldBlockError

const ERROR_TYPE = "WouldBlockError"

func _init(msg : String = "Would block thread"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "Would block thread", default = null):
	return GDRx.raise(WouldBlockError.new(msg), default)
