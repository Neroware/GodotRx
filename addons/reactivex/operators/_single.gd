static func single_(
	predicate = null
) -> Callable:
	
#	"""Returns the only element of an observable sequence that satisfies the
#	condition in the optional predicate, and reports an error if there
#	is not exactly one element in the observable sequence.
#
#	Example:
#		>>> var res = GDRx.op.single()
#		>>> var res = GDRx.op.single(func(x): return x == 42)
#
#	Args:
#		predicate -- [Optional] A predicate function to evaluate for
#			elements in the source sequence.
#
#	Returns:
#		An observable sequence containing the single element in the
#		observable sequence that satisfies the condition in the predicate.
#	"""
	
	if predicate != null:
		var _predicate : Callable = predicate
		return GDRx.pipe.compose2(
			GDRx.op.filter(_predicate),
			GDRx.op.single()
		)
	else:
		return GDRx.op.single_or_default_async(false)
