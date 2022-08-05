static func finally_action_(
	action : Callable
) -> Callable:
	var finally_action = func(source: Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var subscription = source.subscribe(observer, func(e):return, func():return, scheduler)
			
			var dispose = func():
				subscription.dispose()
				action.call()
			
			return Disposable.new(dispose)
		
		return Observable.new(subscribe)
	
	return finally_action
