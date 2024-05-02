extends ThrowableBase
class_name RxBaseError

const BASE_ERROR_TAG = "Error"

var _msg : String
var _tags : ArraySet

func _init(msg : String, tag = "Error"):
	self._msg = msg
	self._tags = ArraySet.new()
	self._tags.add(BASE_ERROR_TAG)
	self._tags.add(tag)

func _to_string() -> String:
	return "[" + self.tags().back() + "::" + self._msg + "]"

func get_message() -> String:
	return self._msg

func throw(default = null) -> Variant:
	return ErrorHandler.singleton().raise(self, default)

func tags() -> Array[String]:
	var txs : Array[String] = []
	for t in self._tags.to_list():
		txs.append(t as String)
	return txs

static func raise(default = null, msg : String = "An error occured"):
	return GDRx.raise(RxBaseError.new(msg), default)
