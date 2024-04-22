static func skip_(count : int) -> Callable:
	if count < 0:
		ArgumentOutOfRangeError.new().throw()
		count = 0
	
	var skip = func(source : Observable) -> Observable:
#		"""The skip operator.
#
#		Bypasses a specified number of elements in an observable sequence
#		and then returns the remaining elements.
#
#		Args:
#			source: The source observable.
#
#		Returns:
#			An observable sequence that contains the elements that occur
#			after the specified index in the input sequence.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var remaining = RefValue.Set(count)
			
			var on_next = func(value):
				if remaining.v <= 0:
					observer.on_next(value)
				else:
					remaining.v -= 1
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return skip
