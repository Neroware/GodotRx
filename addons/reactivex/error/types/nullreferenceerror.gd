extends RxBaseError
class_name NullReferenceError

const ERROR_TYPE = "NullReferenceError"

func _init(msg : String = "Instance not set to a value"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "Instance not set to a value", default = null):
	return GDRx.raise(NullReferenceError.new(msg), default)
