static func skip_last_(count : int) -> Callable:
	var skip_last = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var q : Array = []
			
			var on_next = func(value):
				var front = null
				source._lock.lock()
				q.append(value)
				if q.size() > count:
					front = q.pop_front()
				source._lock.unlock()
				
				if front != null:
					observer.on_next(front)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return skip_last
