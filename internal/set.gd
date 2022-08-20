class_name ArraySet

## A Set data structure based on a list

var _list : Array

func _init():
	self._list = []

func to_list() -> Array:
	return _list.duplicate()

func add(item):
	if not item in self._list:
		self._list.append(item)

func erase(item):
	return self._list.erase(item)

func size() -> int:
	return self._list.size()

func at(index : int):
	return self._list[index]
