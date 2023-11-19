static func is_empty_() -> Callable:
#	"""Determines whether an observable sequence is empty.
#
#	Returns:
#		An observable sequence containing a single element
#		determining whether the source sequence is empty.
#	"""
	
	var mapper = func(b : bool) -> bool:
		return not b
	
	return GDRx.pipe.compose2(
		GDRx.op.some(),
		GDRx.op.map(mapper)
	)
