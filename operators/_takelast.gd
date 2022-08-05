static func take_last_(count : int) -> Callable:
	var take_last = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var q : Array = []
			
			var on_next = func(x):
				q.append(x)
				if q.size() > count:
					q.pop_front()
			
			var on_completed = func():
				while !q.is_empty():
					observer.on_next(q.pop_front())
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return take_last
