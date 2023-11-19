static func materialize_() -> Callable:
	var materialize = func(source : Observable) -> Observable:
#		"""Partially applied materialize operator.
#
#		Materializes the implicit notifications of an observable
#		sequence as explicit notification values.
#
#		Args:
#			source: Source observable to materialize.
#
#		Returns:
#			An observable sequence containing the materialized
#			notification values from the source sequence.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		):
			var on_next = func(value):
				observer.on_next(OnNextNotification.new(value))
			
			var on_error = func(error):
				observer.on_next(OnErrorNotification.new(error))
				observer.on_completed()
			
			var on_completed = func():
				observer.on_next(OnCompletedNotification.new())
				observer.on_completed()
			
			return source.subscribe(
				on_next, on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return materialize
