static func skip_with_time_(
	duration : float, 
	scheduler : SchedulerBase = null
) -> Callable:
	var skip_with_time = func(source : Observable) -> Observable:
#		"""Skips elements for the specified duration from the start of
#		the observable source sequence.
#
#		Args:
#			>>> var res = GDRx.op.skip_with_time(5.0)
#
#		Specifying a zero value for duration doesn't guarantee no
#		elements will be dropped from the start of the source sequence.
#		This is a side-effect of the asynchrony introduced by the
#		scheduler, where the action that causes callbacks from the
#		source sequence to be forwarded may not execute immediately,
#		despite the zero due time.
#
#		Errors produced by the source sequence are always forwarded to
#		the result sequence, even if the error occurs before the
#		duration.
#
#		Args:
#			duration: Duration for skipping elements from the start of
#			the sequence.
#
#		Returns:
#			An observable sequence with the elements skipped during the
#			specified duration from the start of the source sequence.
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
			
			var action = func(_scheduler : SchedulerBase, _state = null):
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
