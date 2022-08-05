class_name StreamItem

var _payload

class _Unit extends StreamItem:
	func _init():
		self._payload = self
	
	func is_unit() -> bool:
		return true
	
	func _to_string():
		return "__"

func _init(payload = null):
	self._payload = payload

func get_payload():
	return self._payload

func is_unit() -> bool:
	return false

static func Unit() -> _Unit:
	return _Unit.new()
