static func skip_(count : int) -> Callable:
	if count < 0:
		push_error("Argument is out of range!")
		count = 0
	
	var skip = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var remaining = RefValue.Set(count)
			
			var on_next = func(value):
				if remaining.v <= 0:
					observer.on_next(value)
				else:
					remaining.v -= 1
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return skip
