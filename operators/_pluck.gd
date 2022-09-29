static func pluck_(key) -> Callable:
#	"""Retrieves the value of a specified key using dict-like access (as in
#	element[key]) from all elements in the Observable sequence.
#
#	Args:
#		key: The key to pluck.
#
#	Returns a new Observable {Observable} sequence of key values.
#
#	To pluck an attribute of each element, use pluck_attr.
#	"""
	var mapper = func(x : Dictionary):
		return x[key]
	
	return GDRx.op.map(mapper)

static func pluck_attr_(prop : String) -> Callable:
#	"""Retrieves the value of a specified property (using getattr) from
#	all elements in the Observable sequence.
#
#	Args:
#		property: The property to pluck.
#
#	Returns a new Observable {Observable} sequence of property values.
#
#	To pluck values using dict-like access (as in element[key]) on each
#	element, use pluck.
#	"""
	return GDRx.op.map(func(x): return x.get(prop))
