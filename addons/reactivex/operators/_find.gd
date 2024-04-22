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
				var should_run = RefValue.Set(false)
				if GDRx.try(func():
					should_run.v = predicate.call(x, index.v, source)
				) \
				.catch("Error", func(err):
					observer.on_error(err)
				) \
				.end_try_catch(): return
				
				if should_run.v:
					observer.on_next(index.v if yield_index else x)
					observer.on_completed()
				else:
					index.v += 1
			
			var on_completed = func():
				@warning_ignore("incompatible_ternary")
				observer.on_next(-1 if yield_index else null)
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return find_value
