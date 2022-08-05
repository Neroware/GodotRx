static func retry_(retry_count : int = -1) -> Callable:
	
	var retry = func(source : Observable) -> Observable:
		var gen : IterableBase
		if retry_count < 0:
			gen = GDRx.util.Infinite(source)
		else:
			var _gen_lst = [] ; for __ in range(retry_count): _gen_lst.append(source)
			gen = GDRx.util.Iter(_gen_lst)
		
		return GDRx.obs.catch_with_iterable(gen)
	
	return retry
