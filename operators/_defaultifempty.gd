static func default_if_empty_(
	default_value = null
) -> Callable:
	var default_if_empty = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var found = [false]
			
			var on_next = func(x):
				found[0] = true
				observer.on_next(x)
			
			var on_completed = func():
				if not found[0]:
					observer.on_next(default_value)
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return default_if_empty
