static func empty_(scheduler : SchedulerBase = null) -> Observable:
	
	var subscribe = func(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase:
		var _scheduler = scheduler if scheduler != null else ImmediateScheduler.singleton()
		
		var action = func(scheduler : SchedulerBase, state):
			observer.on_completed()
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)
