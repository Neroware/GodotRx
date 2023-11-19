static func repeat_(
	repeat_count = null
) -> Callable:
	
	var repeat = func(source : Observable) -> Observable:
#		"""Repeats the observable sequence a specified number of times.
#		If the repeat count is not specified, the sequence repeats
#		indefinitely.
#
#		Examples:
#			>>> var repeated = source.pipe1(GDRx.op.repeat())
#			>>> var repeated = source.pipe1(GDRx.op.repeat(42))
#
#		Args:
#			source: The observable source to repeat.
#
#		Returns:
#			The observable sequence producing the elements of the given
#			sequence repeatedly.
#		"""
		var gen : IterableBase
		if repeat_count == null:
			gen = InfiniteIterable.new(source)
		else:
			var repeat_count_ : int = repeat_count
			var repeats_ : Array[Observable] = []
			for __ in range(repeat_count_): repeats_.append(source)
			gen = GDRx.to_iterable(repeats_)
		
		return GDRx.obs.defer(
			func(__): return GDRx.obs.concat_with_iterable(gen)
		)
	
	return repeat
