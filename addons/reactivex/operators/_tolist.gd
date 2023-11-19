static func to_list_() -> Callable:
	var to_list = func(source : Observable) -> Observable:
		
		var _source = RefValue.Set(source)
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var queue = RefValue.Set([])
			
			var on_next = func(item):
				queue.v.append(item)
			
			var on_completed = func():
				observer.on_next(queue.v)
				queue.v = []
				observer.on_completed()
			
			return _source.v.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return to_list
