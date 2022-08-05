static func defer_(factory : Callable = func(scheduler : SchedulerBase) -> Observable: return null) -> Observable:
	
	var subscribe = func(
		observer : ObserverBase, 
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var result = factory.call(scheduler if scheduler != null else ImmediateScheduler.singleton())
		if not result is Observable:
			return GDRx.obs.throw(GDRx.err.FactoryFailedException.new(null, result)).subscribe(observer)
		
		return result.subscribe(observer, func(e):return, func():return, scheduler)
	
	return Observable.new(subscribe)
