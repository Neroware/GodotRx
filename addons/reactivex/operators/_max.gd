static func max_(comparer = null) -> Callable:
#	"""Returns the maximum value in an observable sequence according to
#	the specified comparer.
#
#	Examples:
#		>>> op = GDRx.op.max()
#		>>> op = GDRx.op.max(func(x, y): return x.value - y.value)
#
#	Args:
#		comparer: [Optional] Comparer used to compare elements.
#
#	Returns:
#		An operator function that takes an observable source and returns
#		an observable sequence containing a single element with the
#		maximum element in the source sequence.
#	"""
	return GDRx.pipe.compose2(
		GDRx.op.max_by(GDRx.basic.identity, comparer),
		GDRx.op.map(func(x : Array): return GDRx.op._Min_.first_only(x))
	)

