static func pairwise_() -> Callable:
	var pairwise = func(source : Observable) -> Observable:
#		"""Partially applied pairwise operator.
#
#		Returns a new observable that triggers on the second and
#		subsequent triggerings of the input observable. The Nth
#		triggering of the input observable passes the arguments from
#		the N-1th and Nth triggering as a pair. The argument passed to
#		the N-1th triggering is held in hidden internal state until the
#		Nth triggering occurs.
#
#		Returns:
#			An observable that triggers on successive pairs of
#			observations from the input observable as an array.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			_scheduler : SchedulerBase = null
		) -> DisposableBase:
			var has_previous = RefValue.Set(false)
			var previous = RefValue.Null()
			
			var on_next = func(x):
				var pair = null
				
				if true:
					var __ = LockGuard.new(source.lock)
					if has_previous.v:
						pair = Tuple.new([previous.v, x])
					else:
						has_previous.v = true
					previous.v = x
				
				if pair != null:
					observer.on_next(pair)
			
			return source.subscribe(on_next, observer.on_error, observer.on_completed)
		
		return Observable.new(subscribe)
	
	return pairwise
