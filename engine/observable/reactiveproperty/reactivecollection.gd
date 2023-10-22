extends ReactiveCollectionBase
class_name ReactiveCollection

var _observers : Dictionary
var _rwlock : ReadWriteLock

var is_disposed : bool

func _get_subscription(event_class, notify_count = false) -> Callable:
	var wself : WeakRef = weakref(self)
	
	return func(observer : ObserverBase, _scheduler : SchedulerBase = null) -> DisposableBase:
		var prop : ReactiveCollection = wself.get_ref()
		
		if not prop or prop.is_disposed:
			observer.on_completed()
			return Disposable.new()
		
		if notify_count:
			observer.on_next(prop.Count)
		
		if true:
			var __ = ReadWriteLockGuard.new(prop._rwlock, false)
			if not (event_class in prop._observers):
				prop._observers[event_class] = []
			prop._observers[event_class].push_back(observer)
		
		var dispose_ = func():
			var _prop = wself.get_ref()
			if not _prop:
				return
			var __ = ReadWriteLockGuard.new(prop._rwlock, false)
			prop._observers[event_class].erase(observer)
		
		return Disposable.new(dispose_)

func _notify_all(event_class, event):
	var observers_ : Array
	if true:
		var __ = ReadWriteLockGuard.new(self._rwlock, true)
		if event_class in self._observers:
			observers_ = self._observers[event_class].duplicate()
	for observer in observers_:
		observer.on_next(event)

func _disconnect_all(event_class):
	var observers_ : Array
	if true:
		var __ = ReadWriteLockGuard.new(this._rwlock, true)
		if event_class in this._observers:
			observers_ = this._observers[event_class].duplicate()
	for observer in observers_:
		observer.on_completed()

func _init(collection = []):
	super._init()
	
	self._observers = {}
	self._rwlock = ReadWriteLock.new()
	self.is_disposed = false
	
	var it : Iterator = GDRx.iter(collection)
	while it.has_next():
		super.add_item(it.next())
	
	self._observe_add = Observable.new(self._get_subscription(CollectionAddEvent))
	self._observe_move = Observable.new(self._get_subscription(CollectionMoveEvent))
	self._observe_remove = Observable.new(self._get_subscription(CollectionRemoveEvent))
	self._observe_replace = Observable.new(self._get_subscription(CollectionReplaceEvent))
	self._observe_reset = Observable.new(self._get_subscription("Reset"))

func ObserveCountChanged(notify_current_count : bool = false) -> Observable:
	return Observable.new(self._get_subscription("CountChanged", notify_current_count)).oftype(TYPE_INT)

## Override from [Comparable]
func eq(other : Comparable) -> bool:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw(false)
	return super.eq(other)

func add_item(item) -> int:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw(-1)
	var index = super.add_item(item)
	var event_add = CollectionAddEvent.new(index, item)
	self._notify_all(CollectionAddEvent, event_add)
	self._notify_all("CountChanged", self._count)
	return index

func remove_item(item) -> int:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw(-1)
	var index = super.remove_item(item)
	if index >= 0:
		var event_remove = CollectionRemoveEvent.new(index, item)
		self._notify_all(CollectionRemoveEvent, event_remove)
		self._notify_all("CountChanged", self._count)
	return index

func remove_at(index : int) -> Variant:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	var value = super.remove_at(index)
	if value != null:
		var event_remove = CollectionRemoveEvent.new(index, value)
		self._notify_all(CollectionRemoveEvent, event_remove)
		self._notify_all("CountChanged", self._count)
	return value

func replace_item(item, with) -> int:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	if GDRx.eq(item, with):
		return self._data.find(item)
	var index : int = super.replace_item(item, with)
	if index >= 0:
		var event_replace = CollectionReplaceEvent.new(index, item, with)
		self._notify_all(CollectionReplaceEvent, event_replace)
	return index

func replace_at(index : int, item) -> Variant:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	var value = super.replace_at(index, item)
	if value != null and GDRx.neq(value, item):
		var event_replace = CollectionReplaceEvent.new(index, value, item)
		self._notify_all(CollectionReplaceEvent, event_replace)
	return value

func swap(idx1 : int, idx2 : int) -> Tuple:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	if idx1 >= self._count or idx2 >= self._count:
		return
	var pair = super.swap(idx1, idx2)
	if GDRx.eq(pair.at(0), pair.at(1)):
		return pair
	var event_move1 = CollectionMoveEvent.new(idx1, idx2, pair.at(0))
	var event_move2 = CollectionMoveEvent.new(idx2, idx1, pair.at(1))
	self._notify_all(CollectionMoveEvent, event_move1)
	self._notify_all(CollectionMoveEvent, event_move2)
	return pair

func move_to(old_index : int, new_index : int):
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	if old_index >= self._count or new_index >= self._count or old_index == new_index:
		return
	var moved = self._data[old_index]
	super.move_to(old_index, new_index)
	var event_move = CollectionMoveEvent.new(old_index, new_index, moved)
	self._notify_all(CollectionMoveEvent, event_move)

func insert_at(index : int, elem):
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	if index > self._count:
		return
	super.insert_at(index, elem)
	var event_add = CollectionAddEvent.new(index, elem)
	self._notify_all(CollectionAddEvent, event_add)
	self._notify_all("CountChanged", self._count)

func at(index : int):
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	return super.at(index)

func find(item) -> int:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw(-1)
	return super.find(item)

func reset():
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	var c = self._count
	super.reset()
	self._notify_all("Reset", StreamItem.Unit())
	if self._count != c:
		self._notify_all("CountChanged", self._count)

func iter() -> Iterator:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	return GDRx.iter(self._data)

func to_list() -> Array:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw([])
	return self._data.duplicate()

func size() -> int:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw(-1)
	return self._count

func dispose():
	if this.is_disposed:
		return
	this.is_disposed = true
	
	this._disconnect_all(CollectionAddEvent)
	this._disconnect_all(CollectionMoveEvent)
	this._disconnect_all(CollectionRemoveEvent)
	this._disconnect_all(CollectionReplaceEvent)
	this._disconnect_all("Reset")
	this._disconnect_all("CountChanged")
	
	this._data = []
	this._count = -1
	this._observers = {}

func to_readonly() -> ReadOnlyReactiveCollection:
	return ReadOnlyReactiveCollection.new(self)

func _to_string() -> String:
	if self.is_disposed:
		return "<<Disposed ReactiveCollection>>"
	return str(self._data)
