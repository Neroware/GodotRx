static func reduce_(
	accumulator : Callable, seed_ = GDRx.util.GetNotSet()
) -> Callable:
#	"""Applies an accumulator function over an observable sequence,
#	returning the result of the aggregation as a single element in the
#	result sequence. The specified seed value is used as the initial
#	accumulator value.
#
#	For aggregation behavior with incremental intermediate results, see
#	`scan()`.
#
#	Examples:
#		>>> var res = GDRx.op.reduce(func(acc, x): return acc + x)
#		>>> var res = GDRx.op.reduce(func(acc, x): return acc + x, 0)
#
#	Args:
#		accumulator: An accumulator function to be
#			invoked on each element.
#		seed: Optional initial accumulator value.
#
#	Returns:
#		An operator function that takes an observable source and returns
#		an observable sequence containing a single element with the
#		final accumulator value.
#	"""
	if !(is_instance_of(seed_, GDRx.util.NotSet)):
		var _seed = seed_
		var scanner = GDRx.op.scan(accumulator, _seed)
		return GDRx.pipe.compose2(
			scanner,
			GDRx.op.last_or_default(_seed)
		)
	
	return GDRx.pipe.compose2(
		GDRx.op.scan(accumulator),
		GDRx.last()
	)
