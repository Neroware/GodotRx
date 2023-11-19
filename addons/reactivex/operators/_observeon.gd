static func observe_on_(scheduler : SchedulerBase) -> Callable:
	var observe_on = func(source : Observable) -> Observable:
#		"""Wraps the source sequence in order to run its observer
#		callbacks on the specified scheduler.
#
#		This only invokes observer callbacks on a scheduler. In case
#		the subscription and/or unsubscription actions have
#		side-effects that require to be run on a scheduler, use
#		subscribe_on.
#
#		Args:
#			source: Source observable.
#
#
#		Returns:
#			Returns the source sequence whose observations happen on
#			the specified scheduler.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			subscribe_scheduler : SchedulerBase = null
		) -> DisposableBase:
			return source.subscribe(
				ObserveOnObserver.new(scheduler, observer),
				GDRx.basic.noop, GDRx.basic.noop,
				subscribe_scheduler
			)
		
		return Observable.new(subscribe)
	
	return observe_on
