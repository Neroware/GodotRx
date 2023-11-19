static func skip_until_with_time_(
	start_time : float,
	time_absolute : bool = false,
	scheduler : SchedulerBase = null
) -> Callable:
	var skip_until_with_time = func(source : Observable) -> Observable:
#		"""Skips elements from the observable source sequence until the
#		specified start time.
#
#		Errors produced by the source sequence are always forwarded to
#		the result sequence, even if the error occurs before the start
#		time.
#
#		Examples:
#			>>> var res = source.pipe1(GDRx.op.skip_until_with_time(datetime))
#			>>> var res = source.pipe1(GDRx.op.skip_until_with_time(5.0))
#
#		Args:
#			start_time: Time to start taking elements from the source
#				sequence. If this value is less than or equal to
#				`datetime.utcnow`, no elements will be skipped.
#
#		Returns:
#			An observable sequence with the elements skipped until the
#			specified start time.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
			var open = [false]
			
			var on_next = func(x):
				if open[0]:
					observer.on_next(x)
			
			var subscription = source.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler_
			)
			
			var action = func(_scheduler : SchedulerBase, _state = null):
				open[0] = true
			
			var disp : DisposableBase
			if time_absolute:
				disp = _scheduler.schedule_absolute(start_time, action)
			else:
				disp = _scheduler.schedule_relative(start_time, action)
			return CompositeDisposable.new([disp, subscription])
		
		return Observable.new(subscribe)
	
	return skip_until_with_time
