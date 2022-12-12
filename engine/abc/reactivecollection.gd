extends Comparable
class_name ReactiveCollectionBase

class CollectionAddEvent extends Comparable:
	var index : int
	var value
	
	func _init(index : int, value):
		self.index = index
		self.value = value
	
	func  _to_string() -> String:
		return "Index: " + str(index) + " Value: " + str(value)
	
	func get_hash_code() -> int:
		return hash(index) ^ hash(value) << 2
	
	func eq(other_ : Comparable) -> bool:
		if not (other_ is ReactiveCollectionBase.CollectionAddEvent):
			return false
		var other = other_ as ReactiveCollectionBase.CollectionAddEvent
		if index != other.index:
			return false
		if value is Comparable:
			return value.eq(other.value)
		return value == other.value

class CollectionRemoveEvent extends Comparable:
	var index : int
	var value
	
	func _init(index : int, value):
		self.index = index
		self.value = value
	
	func  _to_string() -> String:
		return "Index: " + str(index) + " Value: " + str(value)
	
	func get_hash_code() -> int:
		return hash(index) ^ hash(value) << 2
	
	func eq(other_ : Comparable) -> bool:
		if not (other_ is ReactiveCollectionBase.CollectionRemoveEvent):
			return false
		var other = other_ as ReactiveCollectionBase.CollectionRemoveEvent
		if index != other.index:
			return false
		if value is Comparable:
			return value.eq(other.value)
		return value == other.value

class CollectionMoveEvent extends Comparable:
	var old_index : int
	var new_index : int
	var value
	
	func _init(old_index : int, new_index : int, value):
		self.old_index = old_index
		self.new_index = new_index
		self.value = value
	
	func  _to_string() -> String:
		return "OldIndex: " + str(old_index) + " NewIndex: " + str(new_index) \
			+ " Value: " + str(value)
	
	func get_hash_code() -> int:
		return hash(old_index) ^ hash(new_index) << 2 ^ hash(value)
	
	func eq(other_ : Comparable) -> bool:
		if not (other_ is ReactiveCollectionBase.CollectionMoveEvent):
			return false
		var other = other_ as ReactiveCollectionBase.CollectionMoveEvent
		if old_index != other.old_index || new_index != other.new_index:
			return false
		if value is Comparable:
			return value.eq(other.value)
		return value == other.value

class CollectionReplaceEvent extends Comparable:
	var index : int
	var old_value
	var new_value
	
	func _init(index : int, old_value, new_value):
		self.index = index
		self.old_value = old_value
		self.new_value = new_value
	
	func  _to_string() -> String:
		return "Index: " + str(index) + " OldValue: " + str(old_value) \
			+ " NewValue: " + str(new_value)
	
	func get_hash_code() -> int:
		return hash(index) ^ hash(old_value) << 2 ^ hash(new_value)
	
	func eq(other_ : Comparable) -> bool:
		if not (other_ is ReactiveCollectionBase.CollectionReplaceEvent):
			return false
		var other = other_ as ReactiveCollectionBase.CollectionReplaceEvent
		if index != other.index:
			return false
		if old_value is Comparable && !old_value.eq(other.old_value):
			return false
		if old_value != other.old_value:
			return false
		if new_value is Comparable && !new_value.eq(other.new_value):
			return false
		if new_value != other.new_value:
			return false
		return true

var _count : int = 0
var _data : Array = []

var Count : int:
	get: return self.size()

## [Observable]<[ReactiveCollectionBase.CollectionAddEvent]>
var ObserveAdd : Observable:
	get: return self._observe_add.oftype(ReactiveCollectionBase.CollectionAddEvent)
var _observe_add : Observable

## [Observable]<[int]>
func ObserveCountChanged(_notify_current_count : bool = false) -> Observable:
	return GDRx.exc.NotImplementedException.Throw(false)

## [Observable]<[ReactiveCollectionBase.CollectionMoveEvent]>
var ObserveMove : Observable:
	get: return self._observe_move.oftype(ReactiveCollectionBase.CollectionMoveEvent)
var _observe_move : Observable

## [Observable]<[ReactiveCollectionBase.CollectionRemoveEvent]>
var ObserveRemove : Observable:
	get: return self._observe_remove.oftype(ReactiveCollectionBase.CollectionRemoveEvent)
var _observe_remove : Observable

## [Observable]<[ReactiveCollectionBase.CollectionReplaceEvent]>
var ObserveReplace : Observable:
	get: return self._observe_replace.oftype(ReactiveCollectionBase.CollectionReplaceEvent) 
var _observe_replace : Observable

## [Observable]<[StreamItem._Unit]>
var ObserveReset : Observable:
	get: return self._observe_reset.oftype(StreamItem._Unit)
var _observe_reset : Observable

## Override from [Comparable]
func eq(other_ : Comparable) -> bool:
	if not (other_ is ReactiveCollectionBase):
		return false
	var other : ReactiveCollectionBase = other_ as ReactiveCollectionBase
	return self._data.hash() == other._data.hash()

func add_item(item) -> int:
	self._data.append(item)
	self._count += 1
	return self._count - 1

func remove_item(item) -> int:
	var index = self._data.find(item)
	if index >= 0:
		self._data.remove_at(index)
	self._count = self._data.size()
	return index

func remove_at(index : int) -> Variant:
	var value = self._data[index]
	self._data.remove_at(index)
	self._count = self._data.size()
	return value

func replace_item(item) -> Tuple:
	var index = self._data.find(item)
	if index < 0:
		return null
	var value = self._data[index]
	self._data[index] = item
	return Tuple.new([index, value])

func replace_at(index : int, item) -> Variant:
	var value = self._data[index]
	self._data[index] = item
	return value

func swap(idx1 : int, idx2 : int):
	var tmp = self._data[idx1]
	self._data[idx1] = self._data[idx2]

func move_to(curr_index : int, new_index : int):
	var tmp = self._data[curr_index]
	self._data.remove_at(curr_index)
	self._data.insert(new_index, tmp)

func insert_at(index : int, elem):
	self._data.insert(index, elem)
	self._count += 1

func at(index : int):
	return self._data[index]

func find(item) -> int:
	return self._data.find(item)

func reset():
	self._data.clear()
	self._count = 0

func to_list() -> Array:
	return self._data.duplicate()

func size() -> int:
	return self._count

func dispose():
	GDRx.exc.NotImplementedException.Throw()
