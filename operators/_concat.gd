static func concat_(sources : Array[Observable]) -> Callable:
	var concat = func(source : Observable) -> Observable:
		return GDRx.obs.concat_with_iterable(GDRx.util.Iter([source] + sources))
	
	return concat
