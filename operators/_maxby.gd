static func max_by_(
	key_mapper : Callable,
	comparer = null
) -> Callable:
	var cmp = comparer if comparer != null else GDRx.basic.default_sub_comparer
	
	var max_by = func(source : Observable) -> Observable:
#		"""Partially applied max_by operator.
#
#		Returns the elements in an observable sequence with the maximum
#		key value.
#
#		Examples:
#			>>> var res = max_by.call(source)
#
#		Args:
#			source: The source observable sequence to.
#
#		Returns:
#			An observable sequence containing a list of zero or more
#			elements that have a maximum key value.
#		"""
		return GDRx.op.extrema_by(source, key_mapper, cmp)
	
	return max_by
