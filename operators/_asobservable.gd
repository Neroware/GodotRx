static func as_observable_() -> Callable:
	var as_observable = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposbleBase:
			return source.subscribe(observer, func(e):return, func():return, scheduler)
		
		return Observable.new(subscribe)
	
	return as_observable
