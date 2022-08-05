static func take_last_buffer_(count : int) -> Callable:
	var take_last_buffer = func(source : Observable) -> Callable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var q : Array = []
			
			var on_next = func(x):
				source._lock.lock()
				q.append(x)
				if q.size() > count:
					q.pop_front()
				source._lock.unlock()
			
			var on_completed = func():
				observer.on_next(q)
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return take_last_buffer
