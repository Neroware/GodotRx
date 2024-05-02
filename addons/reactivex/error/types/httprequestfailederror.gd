extends RxBaseError
class_name HttpRequestFailedError

const ERROR_TYPE = "HttpRequestFailedError"

var url : String
var error_code : int
var error_message : String

func _init(url_ : String, error_code_ : int, error_message_ : String):
	self.url = url_
	self.error_code = error_code_
	self.error_message = error_message_
	var msg = "HTTP Request to host '" + self.url + "' failed with code " + str(self.error_code) \
		+ ("" if self.error_message.is_empty() else " (" + self.error_message + ")")
	super._init(msg, ERROR_TYPE)

static func raise(default = null, error_message : String = "", url : String = "", error_code : int = -1):
	return GDRx.raise(HttpRequestFailedError.new(url, error_code, error_message), default)
