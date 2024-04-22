extends Comparable
class_name ReadOnlyReactiveDictionaryBase

class DictionaryAddKeyEvent extends Comparable:
	var key
	var value
	
	func _init(key_, value_):
		self.key = key_
		self.value = value_
	
	func  _to_string() -> String:
		return "Key: " + str(key) + " Value: " + str(value)
	
	func get_hash_code() -> int:
		return hash(key) ^ hash(value) << 2
	
	func eq(other) -> bool:
		if not (other is DictionaryAddKeyEvent):
			return false
		return GDRx.eq(key, other.key) and GDRx.eq(value, other.value)

class DictionaryRemoveKeyEvent extends Comparable:
	var key
	var value
	
	func _init(key_, value_):
		self.key = key_
		self.value = value_
	
	func  _to_string() -> String:
		return "Key: " + str(key) + " Value: " + str(value)
	
	func get_hash_code() -> int:
		return hash(key) ^ hash(value) << 2
	
	func eq(other) -> bool:
		if not (other is DictionaryRemoveKeyEvent):
			return false
		return GDRx.eq(key, other.key) and GDRx.eq(value, other.value)

class DictionaryUpdateValueEvent extends Comparable:
	var key
	var value
	
	func _init(key_, value_):
		self.key = key_
		self.value = value_
	
	func  _to_string() -> String:
		return "Key: " + str(key) + " Value: " + str(value)
	
	func get_hash_code() -> int:
		return hash(key) ^ hash(value) << 2
	
	func eq(other) -> bool:
		if not (other is DictionaryUpdateValueEvent):
			return false
		return GDRx.eq(key, other.key) and GDRx.eq(value, other.value)

var Count : int:
	get: return self.size()

## [Observable]<[ReadOnlyReactiveDictionaryBase.DictionaryAddKeyEvent]>
var ObserveAddKey : Observable:
	get: return self._observe_add_key.oftype(ReadOnlyReactiveDictionaryBase.DictionaryAddKeyEvent)
var _observe_add_key : Observable = GDRx.throw(NotImplementedError.new())

## Creates an [Observable] which emits the dictionary's current key count
## when the size changes.
func ObserveCountChanged(_notify_current_count : bool = false) -> Observable:
	return GDRx.throw(NotImplementedError.new())


## [Observable]<[int]>
var ObserveCount : Observable:
	get: return ObserveCountChanged(true).oftype(TYPE_INT)

## [Observable]<[ReadOnlyReactiveDictionaryBase.DictionaryRemoveKeyEvent]>
var ObserveRemoveKey : Observable:
	get: return self._observe_remove_key.oftype(ReadOnlyReactiveDictionaryBase.DictionaryRemoveKeyEvent)
var _observe_remove_key : Observable = GDRx.throw(NotImplementedError.new())

## [Observable]<[ReadOnlyReactiveDictionaryBase.DictionaryUpdateValueEvent]>
var ObserveUpdateValue : Observable:
	get: return self._observer_update_value.oftype(ReadOnlyReactiveDictionaryBase.DictionaryUpdateValueEvent)
var _observer_update_value : Observable = GDRx.throw(NotImplementedError.new())

var this

func _init():
	this = self
	this.unreference()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()

func to_dict() -> Dictionary:
	NotImplementedError.raise()
	return {}

func find_key(value) -> Variant:
	NotImplementedError.raise()
	return null

func get_value(key, default = null) -> Variant:
	NotImplementedError.raise()
	return null

func has_key(key) -> bool:
	NotImplementedError.raise()
	return false

func has_all(keys : Array) -> bool:
	NotImplementedError.raise()
	return false

func hash() -> int:
	NotImplementedError.raise()
	return 0

func is_empty() -> bool:
	NotImplementedError.raise()
	return false

func keys() -> Array:
	NotImplementedError.raise()
	return []

func size() -> int: 
	NotImplementedError.raise()
	return -1

func values() -> Array:
	NotImplementedError.raise()
	return []

func dispose():
	NotImplementedError.raise()
