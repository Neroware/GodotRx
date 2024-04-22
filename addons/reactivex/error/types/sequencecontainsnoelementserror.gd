extends RxBaseError
class_name SequenceContainsNoElementsError

const ERROR_TYPE = "SequenceContainsNoElementsError"

func _init(msg : String = "The given sequence is empty"):
	super._init(msg, ERROR_TYPE)

static func raise(msg : String = "The given sequence is empty", default = null):
	return GDRx.raise(SequenceContainsNoElementsError.new(msg), default)
