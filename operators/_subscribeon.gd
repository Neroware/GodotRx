static func subscribe_on_(scheduler : SchedulerBase) -> Callable:
	var subscribe_on = func(source : Observable) -> Observable:
#		"""Subscribe on the specified scheduler.
#
#		Wrap the source sequence in order to run its subscription and
#		unsubscription logic on the specified scheduler. This operation
#		is not commonly used; see the remarks section for more
#		information on the distinction between subscribe_on and
#		observe_on.
#
#		This only performs the side-effects of subscription and
#		unsubscription on the specified scheduler. In order to invoke
#		observer callbacks on a scheduler, use observe_on.
#
#		Args:
#			source: The source observable..
#
#		Returns:
#			The source sequence whose subscriptions and
#			un-subscriptions happen on the specified scheduler.
#		"""
		var subscribe = func(
			observer : ObserverBase, __ : SchedulerBase = null
		) -> DisposableBase:
			var m = SingleAssignmentDisposable.new()
			var d = SerialDisposable.new()
			d.disposable = m
			
			var action = func(scheduler : SchedulerBase, _state = null):
				d.disposable = ScheduledDisposable.new(
					scheduler, source.subscribe(observer)
				)
			
			m.disposable = scheduler.schedule(action)
			return d
		
		return Observable.new(subscribe)
	
	return subscribe_on
