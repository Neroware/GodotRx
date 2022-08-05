static func ignore_elements_() -> Callable:
	var ignore_elements = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, 
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			return source.subscribe(
				func(__):return,
				observer.on_error,
				observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return ignore_elements
