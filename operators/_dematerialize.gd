static func dematerialize_() -> Callable:
	var dematerialize = func(source : Observable) -> Observable:
#		"""Partially applied dematerialize operator.
#
#		Dematerializes the explicit notification values of an
#		observable sequence as implicit notifications.
#
#		Returns:
#			An observable sequence exhibiting the behavior
#			corresponding to the source sequence's notification values.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_next = func(value : Notification):
				return value.accept(observer)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return dematerialize
