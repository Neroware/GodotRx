static func start_with_(args : Array) -> Callable:
	var start_with = func(source : Observable) -> Observable:
		"""Partially applied start_with operator.

		Prepends a sequence of values to an observable sequence.

		Example:
			>>> start_with.call(source)

		Returns:
			The source sequence prepended with the specified values.
		"""
		var start = GDRx.obs.from_iterable(GDRx.util.Iter(args))
		var sequence = [start, source]
		return GDRx.obs.concat_with_iterable(GDRx.util.Iter(sequence))
	
	return start_with
