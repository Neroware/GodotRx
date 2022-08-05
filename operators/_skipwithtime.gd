static func skip_with_time_(
	duration : float, 
	scheduler : SchedulerBase = null
) -> Callable:
	var skip_with_time = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = TimeoutScheduler.singleton()
			var open = [false]
			
			var action = func(scheduler : SchedulerBase, state = null):
				open[0] = true
			
			var t = _scheduler.schedule_relative(duration, action)
			
			var on_next = func(x):
				if open[0]:
					observer.on_next(x)
			
			var d = source.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler_
			)
			return CompositeDisposable.new([t, d])
		
		return Observable.new(subscribe)
	
	return skip_with_time
