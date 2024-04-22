extends RxBaseError
class_name BadArgumentError

const ERROR_TYPE = "BadArgumentError"

func _init(msg : String = "An argument contained bad input"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "An argument contained bad input", default = null):
	return GDRx.raise(BadArgumentError.new(msg), default)
