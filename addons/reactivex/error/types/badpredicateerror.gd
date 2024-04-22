extends RxBaseError
class_name BadPredicateError

const ERROR_TYPE = "BadPredicateError"

func _init(msg : String = "A predicate failed"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "A predicate failed", default = null):
	return GDRx.raise(BadPredicateError.new(msg), default)
