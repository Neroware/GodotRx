static func scan_(
	accumulator : Callable,
	seed = GDRx.util.GetNotSet()
) -> Callable:
	var has_seed = !(seed is GDRx.util.NotSet)
	
	var scan = func(source : Observable) -> Observable:
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
