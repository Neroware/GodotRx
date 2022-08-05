static func find_value_(
	predicate : Callable, yield_index : bool
) -> Callable:
	var find_value = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var index = RefValue.Set(0)
			
			var on_next = func(x):
				var should_run = false
				should_run = predicate.call(x, index.v, source)
				if should_run is GDRx.err.Error:
					observer.on_error(should_run)
					return
				
				if should_run:
					observer.on_next(index.v if yield_index else x)
					observer.on_completed()
				else:
					index.v += 1
			
			var on_completed = func():
				observer.on_next(-1 if yield_index else null)
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return find_value
