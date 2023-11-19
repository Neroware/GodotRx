static func skip_until_(other : Observable) -> Callable:
#	"""Returns the values from the source observable sequence only after
#	the other observable sequence produces a value.
#
#	Args:
#		other: The observable sequence that triggers propagation of
#			elements of the source sequence.
#
#	Returns:
#		An observable sequence containing the elements of the source
#	sequence starting from the point the other sequence triggered
#	propagation.
#	"""
	
	var obs : Observable = other
	
	var skip_until = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var is_open = [false]
			
			var on_next = func(left):
				if is_open[0]:
					observer.on_next(left)
			
			var on_completed = func():
				if is_open[0]:
					observer.on_completed()
			
			var subs = source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
			var subscriptions = CompositeDisposable.new([subs])
			
			var right_subscription = SingleAssignmentDisposable.new()
			subscriptions.add(right_subscription)
			
			var on_next2 = func(__):
				is_open[0] = true
				right_subscription.dispose()
			
			var on_completed2 = func():
				right_subscription.dispose()
			
			right_subscription.disposable = obs.subscribe(
				on_next2, observer.on_error, on_completed2,
				scheduler
			)
			
			return subscriptions
		
		return Observable.new(subscribe)
	
	return skip_until
