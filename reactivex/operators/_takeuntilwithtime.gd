static func take_until_with_time_(
	end_time : float,
	absolute : bool = false,
	scheduler : SchedulerBase = null
) -> Callable:
	var take_until_with_time = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = TimeoutScheduler.singleton()
			
			var action = func(scheduler : SchedulerBase, state = null):
				observer.on_completed()
			
			var task
			if absolute:
				task = _scheduler.schedule_absolute(end_time, action)
			else:
				task = _scheduler.schedule_relative(end_time, action)
			
			return CompositeDisposable.new([
				task, source.subscribe(observer, func(e):return, func():return, scheduler_)
			])
		
		return Observable.new(subscribe)
	
	return take_until_with_time
