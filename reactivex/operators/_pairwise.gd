static func pairwise_() -> Callable:
	var pairwise = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var has_previous = RefValue.Set(false)
			var previous = RefValue.Null()
			
			var on_next = func(x):
				var pair = null
				
				source._lock.lock()
				if has_previous.v:
					pair = Tuple.new([previous.v, x])
				else:
					has_previous.v = true
				previous.v = x
				source._lock.unlock()
				
				if pair != null:
					observer.on_next(pair)
			
			return source.subscribe(on_next, observer.on_error, observer.on_completed)
		
		return Observable.new(subscribe)
	
	return pairwise
