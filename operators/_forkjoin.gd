static func fork_join_(
	args : Array[Observable]
) -> Callable:
	var fork_join = func(source : Observable) -> Observable:
		return GDRx.obs.fork_join([source] + args)
	
	return fork_join
