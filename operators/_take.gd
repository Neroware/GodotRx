static func take_(count : int) -> Callable:
	if count < 0:
		push_error("Argument 'count' is out of range!")
		count = 0
	
	var take = func(source : Observable) -> Observable:
		if count == 0:
			return GDRx.obs.empty()
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var remaining = RefValue.Set(count)
			
			var on_next = func(value):
				if remaining.v > 0:
					remaining.v -= 1
					observer.on_next(value)
					if not bool(remaining.v):
						observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return take
