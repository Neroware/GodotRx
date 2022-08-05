static func throw_(err, scheduler : SchedulerBase = null) -> Observable:
	
	var subscribe = func(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase:
		var _scheduler = scheduler if scheduler != null else ImmediateScheduler.singleton()
		
		var action = func(scheduler : SchedulerBase, state):
			observer.on_error(err)
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)
