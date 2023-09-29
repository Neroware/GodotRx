static func as_observable_() -> Callable:
	var as_observable = func(source : Observable) -> Observable:
#		"""Hides the identity of an observable sequence.
#
#		Args:
#			source: Observable source to hide identity from.
#
#		Returns:
#			An observable sequence that hides the identity of the
#			source sequence.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			return source.subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, scheduler)
		
		return Observable.new(subscribe)
	
	return as_observable
