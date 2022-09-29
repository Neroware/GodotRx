static func exclusive_() -> Callable:
#	"""Performs a exclusive waiting for the first to finish before
#	subscribing to another observable. Observables that come in between
#	subscriptions will be dropped on the floor.
#
#	Returns:
#		An exclusive observable with only the results that
#		happen when subscribed.
#	"""
	var exclusive = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, scheduler : SchedulerBase = null
		) -> DisposableBase:
			var has_current = [false]
			var is_stopped = [false]
			var m = SingleAssignmentDisposable.new()
			var g = CompositeDisposable.new()
			
			g.add(m)
			
			var on_next = func(inner_source : Observable):
				if not has_current[0]:
					has_current[0] = true
					
					var inner_subscription = SingleAssignmentDisposable.new()
					g.add(inner_subscription)
					
					var on_completed_inner = func():
						g.remove(inner_subscription)
						has_current[0] = false
						if is_stopped[0] and g.length == 1:
							observer.on_completed()
					
					inner_subscription.disposable = inner_source.subscribe(
						observer.on_next,
						observer.on_error,
						on_completed_inner,
						scheduler
					)
			
			var on_completed = func():
				is_stopped[0] = true
				if not has_current[0] and g.length == 1:
					observer.on_completed()
			
			m.disposable = source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
			return g
		
		return Observable.new(subscribe)
	
	return exclusive
