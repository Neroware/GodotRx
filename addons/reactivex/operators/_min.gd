static func first_only(x : Array):
	if x.is_empty():
		return SequenceContainsNoElementsError.raise()
	return x[0]

static func min_(
	comparer = null
) -> Callable:
#	"""The `min` operator.
#
#	Returns the minimum element in an observable sequence according to
#	the optional comparer else a default greater than less than check.
#
#	Examples:
#		>>> var res = source.pipe1(GDRx.op.min())
#		>>> var res = source.pipe1(GDRx.op.min(func(x, y): return x.value - y.value))
#
#	Args:
#		comparer: [Optional] Comparer used to compare elements.
#
#	Returns:
#		An observable sequence containing a single element
#		with the minimum element in the source sequence.
#	"""
	return GDRx.pipe.compose2(
		GDRx.op.min_by(GDRx.basic.identity, comparer),
		GDRx.op.map(func(x): return first_only(x))
	)
