static func start_with_(args) -> Callable:
	var start_with = func(source : Observable) -> Observable:
#		"""Partially applied start_with operator.
#
#		Prepends a sequence of values to an observable sequence.
#
#		Example:
#			>>> start_with.call(source)
#
#		Returns:
#			The source sequence prepended with the specified values.
#		"""
		var start = GDRx.obs.from_iterable(GDRx.to_iterable(args))
		var sequence = [start, source]
		return GDRx.obs.concat_with_iterable(GDRx.to_iterable(sequence))
	
	return start_with
