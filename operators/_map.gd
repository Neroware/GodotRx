static func map_(
	mapper : Callable = GDRx.basic.identity
) -> Callable:
	var _mapper = mapper
	
	var map = func(source : Observable) -> Observable:
		
		var subscribe = func(
			obv : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_next = func(value):
				var result = _mapper.call(value)
				if result is GDRx.err.Error:
					obv.on_error(result)
				else:
					obv.on_next(result)
			
			return source.subscribe(
				on_next, obv.on_error, obv.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return map

static func map_indexed_(
	mapper_indexed : Callable = func(value, idx : int): return value
) -> Callable:
	var _mapper_indexed = mapper_indexed
	
	return GDRx.pipe.compose2(
		GDRx.op.zip_with_iterable(GDRx.util.Infinite()),
		GDRx.op.map(func(i : Tuple): return _mapper_indexed.call(i.at(0), i.at(1)))
	)
