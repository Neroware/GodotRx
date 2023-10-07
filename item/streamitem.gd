extends Comparable
class_name StreamItem

## GDRx-own item type

var _payload

## Represents empty [StreamItem]
class _Unit extends StreamItem:
	func _init():
		self._payload = self
		self._payload.unreference()
	
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

func eq(other) -> bool:
	if not (other is StreamItem):
		return GDRx.eq(self._payload, other)
	return (self.is_unit() and other.is_unit()) \
	or GDRx.eq(self._payload, other._payload)

static func Unit() -> _Unit:
	return _Unit.new()

static func GetUnitType() -> GDScript:
	return StreamItem._Unit

func _to_string():
	return str(self._payload)
