extends RxBaseError
class_name SequenceContainsNoElementsError

const ERROR_TYPE = "SequenceContainsNoElementsError"
const ERROR_MESSAGE = "The given sequence is empty"

func _init(msg : String = ERROR_MESSAGE):
	super._init(msg, ERROR_TYPE)

static func raise(default = null, msg : String = ERROR_MESSAGE):
	return GDRx.raise(SequenceContainsNoElementsError.new(msg), default)
