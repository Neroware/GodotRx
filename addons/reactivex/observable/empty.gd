@tool
static func empty_(scheduler : SchedulerBase = null) -> Observable:
	
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler : SchedulerBase
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = ImmediateScheduler.singleton()
		
		var action = func(_scheduler : SchedulerBase, _state):
			observer.on_completed()
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)
