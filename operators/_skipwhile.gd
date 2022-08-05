static func skip_while_(predicate : Callable) -> Callable:
	var skip_while = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var running = RefValue.Set(false)
			
			var on_next = func(value):
				if not running.v:
					var pred_ = predicate.call(value)
					if not pred_ is bool:
						observer.on_error(GDRx.err.BadPredicateException.new())
						return
					running.v = not pred_
				
				if running.v:
					observer.on_next(value)
				
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return skip_while

func skip_while_indexed_(predicate : Callable) -> Callable:
	var indexer = func(x, i : int) -> Tuple:
		return Tuple.new([x, i])
	
	var skipper = func(x : Tuple) -> bool:
		return predicate.call(x.at(0), x.at(1))
	
	var mapper = func(x : Tuple):
		return x.at(0)
	
	return GDRx.pipe.compose3(
		GDRx.op.map_indexed(indexer),
		GDRx.op.skip_while(skipper),
		GDRx.op.map(mapper)
	)
