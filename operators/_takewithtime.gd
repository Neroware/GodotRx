static func take_with_time_(
	duration : float, scheduler : SchedulerBase = null
) -> Callable:
	var take_with_time = func(source : Observable) -> Observable:
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
			
			var disp = _scheduler.schedule_relative(duration, action)
			return CompositeDisposable.new([
				disp, source.subscribe(observer, func(e):return, func():return, 
				scheduler_)
			])
		
		return Observable.new(subscribe)
	
	return take_with_time
