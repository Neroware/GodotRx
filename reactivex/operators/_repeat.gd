static func repeat_(
	repeat_count = null
) -> Callable:
	
	var repeat = func(source : Observable) -> Observable:
		var gen : IterableBase
		if repeat_count == null:
			gen = GDRx.util.Infinite(source)
		else:
			var repeat_count_ : int = repeat_count
			var repeats_ : Array[Observable] = []
			for __ in range(repeat_count_): repeats_.append(source)
			gen = GDRx.util.Iter(repeats_)
		
		return GDRx.obs.defer(
			func(__): return GDRx.obs.concat_with_iterable(gen)
		)
	
	return repeat
