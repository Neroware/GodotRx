static func take_until_with_time_(
	end_time : float,
	absolute : bool = false,
	scheduler : SchedulerBase = null
) -> Callable:
	var take_until_with_time = func(source : Observable) -> Observable:
#		"""Takes elements for the specified duration until the specified end
#		time, using the specified scheduler to run timers.
#
#		Examples:
#			>>> var res = take_until_with_time.call(source)
#
#		Args:
#			source: Source observale to take elements from.
#
#		Returns:
#			An observable sequence with the elements taken
#			until the specified end time.
#		"""
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
