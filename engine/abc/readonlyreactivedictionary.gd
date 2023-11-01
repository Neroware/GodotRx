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
var _observe_add_key : Observable = GDRx.throw(GDRx.exc.NotImplementedException.new())

## Creates an [Observable] which emits the dictionary's current key count
## when the size changes.
func ObserveCountChanged(_notify_current_count : bool = false) -> Observable:
	return GDRx.exc.NotImplementedException.Throw(GDRx.throw(GDRx.exc.NotImplementedException.new()))

## [Observable]<[int]>
var ObserveCount : Observable:
	get: return ObserveCountChanged(true).oftype(TYPE_INT)

## [Observable]<[ReadOnlyReactiveDictionaryBase.DictionaryRemoveKeyEvent]>
var ObserveRemoveKey : Observable:
	get: return self._observe_remove_key.oftype(ReadOnlyReactiveDictionaryBase.DictionaryRemoveKeyEvent)
var _observe_remove_key : Observable = GDRx.throw(GDRx.exc.NotImplementedException.new())

## [Observable]<[ReadOnlyReactiveDictionaryBase.DictionaryUpdateValueEvent]>
var ObserveUpdateValue : Observable:
	get: return self._observer_update_value.oftype(ReadOnlyReactiveDictionaryBase.DictionaryUpdateValueEvent)
var _observer_update_value : Observable = GDRx.throw(GDRx.exc.NotImplementedException.new())

var this

func _init():
	this = self
	this.unreference()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()

func to_dict() -> Dictionary:
	return GDRx.exc.NotImplementedException.Throw({})

func find_key(value) -> Variant:
	return GDRx.exc.NotImplementedException.Throw(null)

func get_value(key, default = null) -> Variant:
	return GDRx.exc.NotImplementedException.Throw(null)

func has_key(key) -> bool:
	return GDRx.exc.NotImplementedException.Throw(false)

func has_all(keys : Array) -> bool:
	return GDRx.exc.NotImplementedException.Throw(false)

func hash() -> int:
	return GDRx.exc.NotImplementedException.Throw(0)

func is_empty() -> bool:
	return GDRx.exc.NotImplementedException.Throw(false)

func keys() -> Array:
	return GDRx.exc.NotImplementedException.Throw([])

func size() -> int: 
	return GDRx.exc.NotImplementedException.Throw(-1)

func values() -> Array:
	return GDRx.exc.NotImplementedException.Throw([])

func dispose():
	GDRx.exc.NotImplementedException.Throw()
