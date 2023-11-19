class_name PriorityQueue

## Implementation of a priority queue using a heap
## 
## Priority queue using a heap data structure, see: [b]res://addons/reactivex/internal/heap.gd[/b]

var _Heap = GDRx.heap

const MIN_COUNT = 9223372036854775807

var _items : Array
var _count : int

func _init():
	self._items = []
	self._count = MIN_COUNT

func size():
	return _items.size()

func is_empty() -> bool:
	return self.size() == 0

func peek():
	return self._items[0].at(0)

func dequeue() -> Variant:
	var item = _Heap.heappop(self._items).at(0)
	if self._items == null or self._items.is_empty():
		self._count = MIN_COUNT
	return item

func enqueue(item):
	_Heap.heappush(self._items, Tuple.new([item, self._count]))
	self._count += 1

func remove(item) -> bool:
	for index in range(self._items.size()):
		var _item = self._items[index]
		if self._item.at(0) == item:
			self._items.pop_at(index)
			_Heap.heapify(self._items)
			return true
	
	return false

func clear():
	self._items = []
	self._count = MIN_COUNT
