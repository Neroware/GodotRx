static func to_iterable_() -> Callable:
	var to_iterable = func(source : Observable) -> Observable:
#		"""Creates an iterable from an observable sequence.
#
#		Returns:
#			An observable sequence containing a single element with an
#			iterable containing all the elements of the source
#			sequence.
#		"""
		var _source = RefValue.Set(source)
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var queue = RefValue.Set([])
			
			var on_next = func(item):
				queue.v.append(item)
			
			var on_completed = func():
				observer.on_next(GDRx.to_iterable(queue.v))
				queue.v = []
				observer.on_completed()
			
			return _source.v.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return to_iterable
