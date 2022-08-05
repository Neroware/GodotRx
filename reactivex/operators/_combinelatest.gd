static func combine_latest_(others : Array[Observable]) -> Callable:
	var combine_latest = func(source : Observable) -> Observable:
		var sources : Array[Observable] = [source] + others
		return GDRx.obs.combine_latest(sources)
	
	return combine_latest
