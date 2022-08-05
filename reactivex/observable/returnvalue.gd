static func return_value_(value, scheduler : SchedulerBase = null) -> Observable:
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = CurrentThreadScheduler.singleton()
		
		var action = func(scheduler : SchedulerBase, state = null):
			observer.on_next(value)
			observer.on_completed()
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)

static func from_callback_(supplier : Callable, scheduler : SchedulerBase = null) -> Observable:
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = CurrentThreadScheduler.singleton()
		
		var action = func(__ : SchedulerBase, ___ = null):
			var res_ = supplier.call()
			if res_ is GDRx.err.Error:
				observer.on_error(res_)
			else:
				observer.on_next(res_)
				observer.on_completed()
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)
