extends ReactiveCollectionBase
class_name ReactiveCollection

var _observers : Dictionary
var _rwlock : ReadWriteLock

var is_disposed : bool

func _get_subscription(event_class, notify_count = false) -> Callable:
	return func(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase:
		if self.is_disposed:
			observer.on_completed()
			return Disposable.new()
		
		if notify_count:
			observer.on_next(self.Count)
		
		self._rwlock.w_lock()
		if not (event_class in self._observers):
			self._observers[event_class] = []
		self._observers[event_class].push_back(observer)
		self._rwlock.w_unlock()
		
		var dispose = func():
			self._rwlock.w_lock()
			self._observers[event_class].erase(observer)
			self._rwlock.w_unlock()
		
		return Disposable.new(dispose)

func _notify_all(event_class, event):
	var _observers : Array
	self._rwlock.r_lock()
	if event_class in self._observers:
		_observers = self._observers[event_class].duplicate()
	self._rwlock.r_unlock()
	for observer in _observers:
		observer.on_next(event)

func _disconnect_all(event_class):
	var _observers : Array
	self._rwlock.r_lock()
	if event_class in self._observers:
		_observers = self._observers[event_class].duplicate()
	self._rwlock.r_unlock()
	for observer in _observers:
		observer.on_completed()

func _init(data : Array = []):
	super._init()
	
	self._observers = {}
	self._rwlock = ReadWriteLock.new()
	self.is_disposed = false
	
	for item in data:
		super.add_item(item)
	
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
	var event_remove = CollectionRemoveEvent.new(index, value)
	self._notify_all(CollectionRemoveEvent, event_remove)
	self._notify_all("CountChanged", self._count)
	return value

func replace_item(item) -> Tuple:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	var result : Tuple = super.replace_item(item)
	var event_replace = CollectionReplaceEvent.new(result.at(0), result.at(1), item)
	self._notify_all(CollectionReplaceEvent, event_replace)
	return result

func replace_at(index : int, item) -> Variant:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	var value = super.replace_at(index, item)
	var event_replace = CollectionReplaceEvent.new(index, value, item)
	self._notify_all(CollectionReplaceEvent, event_replace)
	return value

func swap(idx1 : int, idx2 : int):
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	var elem1 = self._data[idx1]
	var elem2 = self._data[idx2]
	if elem1 == elem2 || (elem1 is Comparable and elem1.eq(elem2)):
		return
	var event_move1 = CollectionMoveEvent.new(idx1, idx2, elem1)
	var event_move2 = CollectionMoveEvent.new(idx2, idx1, elem2)
	super.swap(idx1, idx2)
	self._notify_all(CollectionMoveEvent, event_move1)
	self._notify_all(CollectionMoveEvent, event_move2)

func move_to(old_index : int, new_index : int):
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	var moved = self._data[old_index]
	var replaced = self._data[new_index]
	if moved == replaced || (moved is Comparable and moved.eq(replaced)):
		return
	super.move_to(old_index, new_index)
	var event_move = CollectionMoveEvent.new(old_index, new_index, moved)
	self._notify_all(CollectionMoveEvent, event_move)
	if old_index < new_index:
		for i in range(old_index + 1, new_index):
			var event_move_casc = CollectionMoveEvent.new(i, i - 1, self._data[i - 1])
			self._notify_all(CollectionMoveEvent, event_move_casc)
	elif new_index < old_index:
		for i in range(new_index + 1, old_index):
			var event_move_casc = CollectionMoveEvent.new(i, i + 1, self._data[i + 1])
			self._notify_all(CollectionMoveEvent, event_move_casc)

func insert_at(index : int, elem):
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	super.insert_at(index, elem)
	var event_add = CollectionAddEvent.new(index, elem)
	self._notify_all(CollectionAddEvent, event_add)
	for i in range(index, self._data.size()):
		var event_move_casc = CollectionMoveEvent.new(i, i + 1, self._data[i + 1])
		self._notify_all(CollectionMoveEvent, event_move_casc)

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

func to_list() -> Array:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw()
	return self._data.duplicate()

func size() -> int:
	if self.is_disposed:
		return GDRx.exc.DisposedException.Throw(-1)
	return self._count

func dispose():
	if is_disposed:
		return
	is_disposed = true
	
	self._disconnect_all(CollectionAddEvent)
	self._disconnect_all(CollectionMoveEvent)
	self._disconnect_all(CollectionRemoveEvent)
	self._disconnect_all(CollectionReplaceEvent)
	self._disconnect_all("Reset")
	self._disconnect_all("CountChanged")
	
	self._data = []
	self._count = -1
	self._observers = {}

func _to_string() -> String:
	if self.is_disposed:
		return "<<Disposed ReactiveCollection>>"
	return str(self._data)
