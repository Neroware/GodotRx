static func skip_until_with_time_(
	start_time : float,
	time_absolute : bool = false,
	scheduler : SchedulerBase = null
) -> Callable:
	var skip_until_with_time = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = TimeoutScheduler.singleton()
			
			var open = [false]
			
			var on_next = func(x):
				if open[0]:
					observer.on_next(x)
			
			var subscription = source.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler_
			)
			
			var action = func(scheduler : SchedulerBase, state = null):
				open[0] = true
			
			var disp : DisposableBase
			if time_absolute:
				disp = _scheduler.schedule_absolute(start_time, action)
			else:
				disp = _scheduler.schedule_relative(start_time, action)
			return CompositeDisposable.new([disp, subscription])
		
		return Observable.new(subscribe)
	
	return skip_until_with_time
