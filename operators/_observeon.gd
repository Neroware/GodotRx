static func observe_on_(scheduler : SchedulerBase) -> Callable:
	var observe_on = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			subscribe_scheduler : SchedulerBase = null
		) -> DisposableBase:
			return source.subscribe(
				ObserveOnObserver.new(scheduler, observer),
				func(e):return, func():return,
				subscribe_scheduler
			)
		
		return Observable.new(subscribe)
	
	return observe_on
