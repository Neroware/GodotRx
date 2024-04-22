extends Comparable
class_name ReadOnlyReactiveCollectionBase

class CollectionAddEvent extends Comparable:
	var index : int
	var value
	
	func _init(index_ : int, value_):
		self.index = index_
		self.value = value_
	
	func  _to_string() -> String:
		return "Index: " + str(index) + " Value: " + str(value)
	
	func get_hash_code() -> int:
		return hash(index) ^ hash(value) << 2
	
	func eq(other_ : Comparable) -> bool:
		if not (other_ is ReadOnlyReactiveCollectionBase.CollectionAddEvent):
			return false
		var other = other_ as ReadOnlyReactiveCollectionBase.CollectionAddEvent
		if index != other.index:
			return false
		return GDRx.eq(value, other.value)

class CollectionRemoveEvent extends Comparable:
	var index : int
	var value
	
	func _init(index_ : int, value_):
		self.index = index_
		self.value = value_
	
	func _to_string() -> String:
		return "Index: " + str(index) + " Value: " + str(value)
	
	func get_hash_code() -> int:
		return hash(index) ^ hash(value) << 2
	
	func eq(other_ : Comparable) -> bool:
		if not (other_ is ReadOnlyReactiveCollectionBase.CollectionRemoveEvent):
			return false
		var other = other_ as ReadOnlyReactiveCollectionBase.CollectionRemoveEvent
		if index != other.index:
			return false
		return GDRx.eq(value, other.value)

class CollectionMoveEvent extends Comparable:
	var old_index : int
	var new_index : int
	var value
	
	func _init(old_index_ : int, new_index_ : int, value_):
		self.old_index = old_index_
		self.new_index = new_index_
		self.value = value_
	
	func  _to_string() -> String:
		return "OldIndex: " + str(old_index) + " NewIndex: " + str(new_index) \
			+ " Value: " + str(value)
	
	func get_hash_code() -> int:
		return hash(old_index) ^ hash(new_index) << 2 ^ hash(value)
	
	func eq(other_ : Comparable) -> bool:
		if not (other_ is ReadOnlyReactiveCollectionBase.CollectionMoveEvent):
			return false
		var other = other_ as ReadOnlyReactiveCollectionBase.CollectionMoveEvent
		if old_index != other.old_index || new_index != other.new_index:
			return false
		return GDRx.eq(value, other.value)

class CollectionReplaceEvent extends Comparable:
	var index : int
	var old_value
	var new_value
	
	func _init(index_ : int, old_value_, new_value_):
		self.index = index_
		self.old_value = old_value_
		self.new_value = new_value_
	
	func  _to_string() -> String:
		return "Index: " + str(index) + " OldValue: " + str(old_value) \
			+ " NewValue: " + str(new_value)
	
	func get_hash_code() -> int:
		return hash(index) ^ hash(old_value) << 2 ^ hash(new_value)
	
	func eq(other_ : Comparable) -> bool:
		if not (other_ is ReadOnlyReactiveCollectionBase.CollectionReplaceEvent):
			return false
		var other = other_ as ReadOnlyReactiveCollectionBase.CollectionReplaceEvent
		if index != other.index:
			return false
		return GDRx.eq(old_value, other.old_value) and GDRx.eq(new_value, other.new_value)

var Count : int:
	get: return self.size()

## [Observable]<[ReadOnlyReactiveCollectionBase.CollectionAddEvent]>
var ObserveAdd : Observable:
	get: return self._observe_add.oftype(ReadOnlyReactiveCollectionBase.CollectionAddEvent)
var _observe_add : Observable = GDRx.throw(NotImplementedError.new())

## Creates an [Observable] which emits the collection's current element count
## when the size changes.
func ObserveCountChanged(_notify_current_count : bool = false) -> Observable:
	NotImplementedError.raise()
	return Observable.new()

## [Observable]<[int]>
var ObserveCount : Observable:
	get: return ObserveCountChanged(true).oftype(TYPE_INT)

## [Observable]<[ReadOnlyReactiveCollectionBase.CollectionMoveEvent]>
var ObserveMove : Observable:
	get: return self._observe_move.oftype(ReadOnlyReactiveCollectionBase.CollectionMoveEvent)
var _observe_move : Observable = GDRx.throw(NotImplementedError.new())

## [Observable]<[ReadOnlyReactiveCollectionBase.CollectionRemoveEvent]>
var ObserveRemove : Observable:
	get: return self._observe_remove.oftype(ReadOnlyReactiveCollectionBase.CollectionRemoveEvent)
var _observe_remove : Observable = GDRx.throw(NotImplementedError.new())

## [Observable]<[ReadOnlyReactiveCollectionBase.CollectionReplaceEvent]>
var ObserveReplace : Observable:
	get: return self._observe_replace.oftype(ReadOnlyReactiveCollectionBase.CollectionReplaceEvent) 
var _observe_replace : Observable = GDRx.throw(NotImplementedError.new())

## [Observable]<[StreamItem._Unit]>
var ObserveReset : Observable:
	get: return self._observe_reset.oftype(StreamItem._Unit)
var _observe_reset : Observable = GDRx.throw(NotImplementedError.new())

var this

func _init():
	this = self
	this.unreference()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()

## Override from [Comparable]
func eq(other) -> bool:
	if other is ReadOnlyReactiveCollectionBase:
		return self.to_list().hash() == other.to_list().hash()
	return false

func at(index : int):
	NotImplementedError.raise()
	return null

func find(item) -> int:
	NotImplementedError.raise()
	return -1

func to_list() -> Array:
	NotImplementedError.raise()
	return []

func iter() -> Iterator:
	NotImplementedError.raise()
	return null

func size() -> int:
	NotImplementedError.raise()
	return -1

func dispose():
	NotImplementedError.raise()
