static func throttle_first_(
	window_duration : float,
	scheduler : SchedulerBase = null
) -> Callable:
	var throttle_first = func(source : Observable) -> Observable:
#		"""Returns an observable that emits only the first item emitted
#		by the source Observable during sequential time windows of a
#		specified duration.
#
#		Args:
#			source: Source observable to throttle.
#
#		Returns:
#			An Observable that performs the throttle operation.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
			var duration : float = window_duration
			if duration <= 0:
				ArgumentOutOfRangeError.raise()
			var last_on_next = RefValue.Null()
			
			var on_next = func(x):
				var emit = false
				var now = _scheduler.now()
				
				if true:
					var __ = LockGuard.new(source.lock)
					if last_on_next.v == null or now - last_on_next.v >= duration:
						last_on_next.v = now
						emit = true
				
				if emit:
					observer.on_next(x)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				_scheduler
			)
		
		return Observable.new(subscribe)
	
	return throttle_first
