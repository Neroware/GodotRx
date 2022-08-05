static func while_do_(
	condition : Callable = func(): return true
) -> Callable:
	var while_do = func(source : Observable) -> Observable:
		var obs = source
		var it : IterableBase = GDRx.util.TakeWhile(condition, GDRx.util.Infinite(obs))
		return GDRx.obs.concat_with_iterable(it)
	
	return while_do
