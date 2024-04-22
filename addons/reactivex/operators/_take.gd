static func take_(count : int) -> Callable:
	if count < 0:
		ArgumentOutOfRangeError.raise()
		count = 0
	
	var take = func(source : Observable) -> Observable:
#		"""Returns a specified number of contiguous elements from the start of
#		an observable sequence.
#
#		>>> take.call(source)
#
#		Keyword arguments:
#		count -- The number of elements to return.
#
#		Returns an observable sequence that contains the specified number of
#		elements from the start of the input sequence.
#		"""
		if count == 0:
			return GDRx.obs.empty()
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var remaining = RefValue.Set(count)
			
			var on_next = func(value):
				if remaining.v > 0:
					remaining.v -= 1
					observer.on_next(value)
					if not bool(remaining.v):
						observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return take
