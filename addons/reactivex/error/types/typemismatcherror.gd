extends RxBaseError
class_name TypeMismatchError

const ERROR_TYPE = "TypeMismatchError"
const ERROR_MESSAGE = "Type mismatch"

var _item

func _init(item_, msg_ : String = ERROR_MESSAGE):
	self._item = item_
	var msg = msg_ + ":!" + str(item_)
	super._init(msg, ERROR_TYPE)

func get_item():
	return self._item

static func raise(default = null, msg : String = ERROR_MESSAGE, item = null):
	return GDRx.raise(TypeMismatchError.new(item, msg), default)
