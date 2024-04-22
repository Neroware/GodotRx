extends ReadOnlyReactiveCollectionBase
class_name ReactiveCollectionBase

func reset():
	NotImplementedError.raise()

func add_item(item) -> int:
	NotImplementedError.raise()
	return -1

func remove_item(item) -> int:
	NotImplementedError.raise()
	return -1

func remove_at(index : int) -> Variant:
	NotImplementedError.raise()
	return null

func replace_item(item, with) -> int:
	NotImplementedError.raise()
	return -1

func replace_at(index : int, item) -> Variant:
	NotImplementedError.raise()
	return null

func swap(idx1 : int, idx2 : int) -> Tuple:
	NotImplementedError.raise()
	return Tuple.Empty()

func move_to(curr_index : int, new_index : int):
	NotImplementedError.raise()

func insert_at(index : int, elem):
	NotImplementedError.raise()

