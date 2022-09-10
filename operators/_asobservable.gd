static func as_observable_() -> Callable:
	var as_observable = func(source : Observable) -> Observable:
		"""Hides the identity of an observable sequence.

		Args:
			source: Observable source to hide identity from.

		Returns:
			An observable sequence that hides the identity of the
			source sequence.
		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposbleBase:
			return source.subscribe(observer, func(e):return, func():return, scheduler)
		
		return Observable.new(subscribe)
	
	return as_observable
