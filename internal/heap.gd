## Heap queue algorithm (a.k.a. priority queue).
## See https://github.com/python/cpython/blob/3.10/Lib/heapq.py

func heappush(heap : Array[Comparable], item):
	heap.append(item)
	_siftdown(heap, 0, len(heap) - 1)

func heappop(heap : Array[Comparable]):
	var lastelt = heap.pop_back()
	if heap != null and not heap.is_empty():
		var returnitem = heap[0]
		heap[0] = lastelt
		_siftup(heap, 0)
		return returnitem
	return lastelt

func heapreplace(heap : Array[Comparable], item):
	var returnitem = heap[0]
	heap[0] = item
	_siftup(heap, 0)
	return returnitem

func heappushpop(heap : Array[Comparable], item):
	if heap != null and not heap.is_empty() and heap[0] < item:
		var item_tmp = heap[0]
		heap[0] = item
		item = item_tmp
		_siftup(heap, 0)
	return item

func heapify(x : Array[Comparable]):
	var n = len(x)
	var rang_ = range(int(n / 2.0)) ; rang_.reverse()
	for i in rang_:
		_siftup(x, i)

func _siftdown(heap : Array[Comparable], startpos, pos):
	var newitem = heap[pos]
	while pos > startpos:
		var parentpos = (pos - 1) >> 1
		var parent = heap[parentpos]
		if newitem.lt(parent):
			pos = parentpos
			continue
		break
	heap[pos] = newitem

func _siftup(heap : Array[Comparable], pos):
	var endpos = len(heap)
	var startpos = pos
	var newitem = heap[pos]
	var childpos = 2 * pos + 1
	while childpos < endpos:
		var rightpos = childpos + 1
		if rightpos < endpos and not heap[childpos].lt(heap[rightpos]):
			childpos = rightpos
		heap[pos] = heap[childpos]
		pos = childpos
		childpos = 2 * pos + 1
	heap[pos] = newitem
	_siftdown(heap, startpos, pos)
