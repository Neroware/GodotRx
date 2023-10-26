extends ReadOnlyReactiveCollectionBase
class_name ReadOnlyReactiveCollection

var _collection : ReactiveCollectionBase
var _observers : Array[ObserverBase]

class _Observable extends Observable:
	func _init(source : Observable, observers : Array[ObserverBase]):
		var subscribe_ = func(observer, scheduler = null):
			if not observer in observers:
				observers.push_back(observer)
			return source.subscribe1(observer, scheduler)
		super._init(subscribe_)

func _init(collection : ReactiveCollectionBase):
	self._collection = collection
	self._observe_add = self._Observable.new(collection.ObserveAdd, self._observers)
	self._observe_move = self._Observable.new(collection.ObserveMove, self._observers)
	self._observe_remove = self._Observable.new(collection.ObserveRemove, self._observers)
	self._observe_replace = self._Observable.new(collection.ObserveReplace, self._observers)
	self._observe_reset = self._Observable.new(collection.ObserveReset, self._observers)
	
	super._init()

func ObserveCountChanged(_notify_current_count : bool = false) -> Observable:
	return self._collection.ObserveCountChanged(_notify_current_count)

func at(index : int):
	return self._collection.at(index)

func find(item) -> int:
	return self._collection.find(item)

func to_list() -> Array:
	return self._collection.to_list()

func iter() -> Iterator:
	return self._collection.iter()

func size() -> int:
	return self._collection.size()

func dispose():
	for observer in self._observers:
		observer.on_completed()
