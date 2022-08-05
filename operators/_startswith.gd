static func start_with_(args : Array) -> Callable:
	var start_with = func(source : Observable) -> Observable:
		var start = GDRx.obs.from_iterable(GDRx.util.Iter(args))
		var sequence = [start, source]
		return GDRx.obs.concat_with_iterable(GDRx.util.Iter(sequence))
	
	return start_with
