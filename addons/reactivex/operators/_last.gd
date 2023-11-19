static func last_(predicate = null) -> Callable:
	var last = func(source : Observable) -> Observable:
#		"""Partially applied last operator.
#
#		Returns the last element of an observable sequence that
#		satisfies the condition in the predicate if specified, else
#		the last element.
#
#		Examples:
#			>>> var res = last.call(source)
#
#		Args:
#			source: Source observable to get last item from.
#
#		Returns:
#			An observable sequence containing the last element in the
#			observable sequence that satisfies the condition in the
#			predicate.
#		"""
		if predicate != null:
			var predicate_ : Callable = predicate
			return source.pipe2(
				GDRx.op.filter(predicate_),
				GDRx.op.last()
			)
		
		return GDRx.op.last_or_default_async(source, false)
	
	return last
