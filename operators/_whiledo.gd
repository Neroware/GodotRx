static func while_do_(
	condition : Callable = func(): return true
) -> Callable:
	var while_do = func(source : Observable) -> Observable:
		"""Repeats source as long as condition holds emulating a while
		loop.

		Args:
			source: The observable sequence that will be run if the
				condition function returns true.

		Returns:
			An observable sequence which is repeated as long as the
			condition holds.
		"""
		var obs = source
		var it : IterableBase = GDRx.util.TakeWhile(condition, GDRx.util.Infinite(obs))
		return GDRx.obs.concat_with_iterable(it)
	
	return while_do
