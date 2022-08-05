static func filter_(predicate : Callable = func(x): return true) -> Callable:
	var filter = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_next = func(value):
				var should_run = predicate.call(value)
				if not should_run is bool:
					observer.on_error(GDRx.err.BadPredicateError.new())
					return
				
				if should_run:
					observer.on_next(value)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return filter

static func filter_indexed_(predicate : Callable = func(x, index): return true) -> Callable:
	var filter = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			
			var count = RefValue.Set(0)
			
			var on_next = func(value):
				var should_run = predicate.call(value, count.v)
				if not should_run is bool:
					observer.on_error(GDRx.err.BadPredicateError.new())
					return
				count.v += 1
				if should_run:
					observer.on_next(value)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return filter
