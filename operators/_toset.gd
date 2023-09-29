static func to_set_() -> Callable:
#	"""Converts the observable sequence to a set.
#
#	Returns an observable sequence with a single value of a set
#	containing the values from the observable sequence.
#	"""
	var to_set = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var s = RefValue.Set(ArraySet.new())
			
			var on_completed = func():
				observer.on_next(s.v)
				s.v = ArraySet.new()
				observer.on_completed()
			
			return source.subscribe(
				s.v.add, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return to_set
