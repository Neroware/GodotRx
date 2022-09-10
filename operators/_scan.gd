static func scan_(
	accumulator : Callable,
	seed = GDRx.util.GetNotSet()
) -> Callable:
	var has_seed = !(seed is GDRx.util.NotSet)
	
	var scan = func(source : Observable) -> Observable:
		"""Partially applied scan operator.

		Applies an accumulator function over an observable sequence and
		returns each intermediate result.

		Examples:
			>>> var scanned = scan.call(source)

		Args:
			source: The observable source to scan.

		Returns:
			An observable sequence containing the accumulated values.
		"""
		var factory = func(scheduler : SchedulerBase) -> Observable:
			var has_accumulation = RefValue.Set(false)
			var accumulation = RefValue.Null()
			
			var projection = func(x):
				if has_accumulation.v:
					accumulation.v = accumulator.call(accumulation.v, x)
				else:
					accumulation.v = accumulator.call(seed, x) if has_seed else x
					has_accumulation.v = true
				
				return accumulation.v
			
			return source.pipe1(GDRx.op.map(projection))
		
		return GDRx.obs.defer(factory)
	
	return scan
