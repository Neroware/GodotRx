extends ReadOnlyReactiveCollectionBase
class_name ReactiveCollectionBase

func reset():
	GDRx.exc.NotImplementedException.Throw()

func add_item(item) -> int:
	return GDRx.exc.NotImplementedException.Throw(-1)

func remove_item(item) -> int:
	return GDRx.exc.NotImplementedException.Throw(-1)

func remove_at(index : int) -> Variant:
	return GDRx.exc.NotImplementedException.Throw(null)

func replace_item(item, with) -> int:
	return GDRx.exc.NotImplementedException.Throw(-1)

func replace_at(index : int, item) -> Variant:
	return GDRx.exc.NotImplementedException.Throw(null)

func swap(idx1 : int, idx2 : int) -> Tuple:
	return GDRx.exc.NotImplementedException.Throw(Tuple.Empty())

func move_to(curr_index : int, new_index : int):
	GDRx.exc.NotImplementedException.Throw()

func insert_at(index : int, elem):
	GDRx.exc.NotImplementedException.Throw()

