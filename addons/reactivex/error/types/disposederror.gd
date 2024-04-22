extends RxBaseError
class_name DisposedError

const ERROR_TYPE = "DisposedError"

func _init(msg : String = "The requested element was disposed before"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "The requested element was disposed before", default = null):
	return GDRx.raise(DisposedError.new(msg), default)
