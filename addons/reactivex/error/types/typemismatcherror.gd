extends RxBaseError
class_name TypeMismatchError

const ERROR_TYPE = "TypeMismatchError"

var _item

func _init(item, msg : String = "Type mismatch:!\"" + str(item) + "\""):
	self._item = item
	super._init(msg, ERROR_TYPE)

func get_item():
	return self._item

static func raise(msg : String = "Type mismatch", default = null, item = null):
	return GDRx.raise(TypeMismatchError.new(msg + ":!\"" + str(item) + "\""), default)
