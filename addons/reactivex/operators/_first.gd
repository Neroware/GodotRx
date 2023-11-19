static func first_(
	predicate = null
) -> Callable:
#	"""Returns the first element of an observable sequence that
#	satisfies the condition in the predicate if present else the first
#	item in the sequence.
#
#	Examples:
#		>>> var res = first().call(source)
#		>>> var res = first(func(x): return x > 3).call(source)
#
#	Args:
#		predicate -- [Optional] A predicate function to evaluate for
#			elements in the source sequence.
#
#	Returns:
#		A function that takes an observable source and returns an
#		observable sequence containing the first element in the
#		observable sequence that satisfies the condition in the predicate if
#		provided, else the first item in the sequence.
#	"""
	if predicate != null:
		var predicate_ : Callable = predicate
		return GDRx.pipe.compose2(GDRx.op.filter(predicate_), GDRx.op.first())
	
	return GDRx.op.first_or_default_async(false)
