extends RxBaseError
class_name NotImplementedError

const ERROR_TYPE = "NotImplementedError"

func _init(msg : String = "There is no implementation"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "There is no implementation", default = null):
	return GDRx.raise(NotImplementedError.new(msg), default)
