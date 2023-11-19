static func skip_last_with_time_(
	duration : float, scheduler : SchedulerBase = null
) -> Callable:
#	"""Skips elements for the specified duration from the end of the
#	observable source sequence.
#
#	Example:
#		>>> var res = GDRx.op.skip_last_with_time(5.0)
#
#	This operator accumulates a queue with a length enough to store
#	elements received during the initial duration window. As more
#	elements are received, elements older than the specified duration
#	are taken from the queue and produced on the result sequence. This
#	causes elements to be delayed with duration.
#
#	Args:
#		duration: Duration for skipping elements from the end of the
#			sequence.
#		scheduler: Scheduler to use for time handling.
#
#	Returns:
#		An observable sequence with the elements skipped during the
#	specified duration from the end of the source sequence.
#	"""
	var _duration = RefValue.Set(duration)
	
	var skip_last_with_time = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			_duration.v = duration
			var q : Array[Dictionary] = []
			
			var on_next = func(x):
				var now = _scheduler.now()
				q.append({"interval":now, "value":x})
				while not q.is_empty() and now - q[0]["interval"] >= _duration.v:
					observer.on_next(q.pop_front()["value"])
			
			var on_completed = func():
				var now = _scheduler.now()
				while not q.is_empty() and now - q[0]["interval"] >= _duration.v:
					observer.on_next(q.pop_front()["value"])
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed, 
				_scheduler
			)
		
		return Observable.new(subscribe)
	
	return skip_last_with_time
