static func finally_action_(
	action : Callable
) -> Callable:
	var finally_action = func(source: Observable) -> Observable:
#		"""Invokes a specified action after the source observable
#		sequence terminates gracefully or exceptionally.
#
#		Example:
#			res = finally(source)
#
#		Args:
#			source: Observable sequence.
#
#		Returns:
#			An observable sequence with the action-invoking termination
#			behavior applied.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var subscription = RefValue.Null()
			GDRx.try(func():
				subscription.v = source.subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, scheduler)
			) \
			.catch("Error", func(e):
				action.call()
				GDRx.raise(e)
			) \
			.end_try_catch()
			
			var dispose = func():
				GDRx.try(func():
					subscription.v.dispose()
				).end_try_catch()
				action.call()
			
			return Disposable.new(dispose)
		
		return Observable.new(subscribe)
	
	return finally_action
