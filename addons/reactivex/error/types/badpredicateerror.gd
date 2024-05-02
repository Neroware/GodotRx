extends RxBaseError
class_name BadPredicateError

const ERROR_TYPE = "BadPredicateError"
const ERROR_MESSAGE = "A predicate failed"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(BadPredicateError.new(msg), default)
