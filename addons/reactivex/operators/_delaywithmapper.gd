static func delay_with_mapper_(
	subscription_delay = null,
	delay_duration_mapper = null
) -> Callable:
	var delay_with_mapper = func(source : Observable) -> Observable:
#		"""Time shifts the observable sequence based on a subscription
#		delay and a delay mapper function for each element.
#
#		Examples:
#			>>> var obs = delay_with_selector.call(source)
#
#		Args:
#			subscription_delay: [Optional] Sequence indicating the
#				delay for the subscription to the source.
#			delay_duration_mapper: [Optional] Selector function to
#				retrieve a sequence indicating the delay for each given
#				element.
#
#		Returns:
#			Time-shifted observable sequence.
#		"""
		var sub_delay : Observable = null
		var mapper = null
		
		if subscription_delay is ObservableBase:
			mapper = delay_duration_mapper
			sub_delay = subscription_delay
		else:
			mapper = subscription_delay
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var delays = CompositeDisposable.new()
			var at_end = [false]
			
			var done = func():
				if at_end[0] and delays.length == 0:
					observer.on_completed()
			
			var subscription = SerialDisposable.new()
			
			var start = func():
				var on_next = func(x):
					var delay = RefValue.Null()
					if GDRx.try(func():
						if GDRx.assert_(mapper != null): return
						delay.v = mapper.call(x)
					) \
					.catch("Error", func(error):
						observer.on_error(error)
					) \
					.end_try_catch(): return
					
					var d = SingleAssignmentDisposable.new()
					delays.add(d)
					
					var on_next = func(__):
						observer.on_next(x)
						delays.remove(d)
						done.call()
					
					var on_completed = func():
						observer.on_next(x)
						delays.remove(d)
						done.call()
					
					d.disposable = delay.v.subscribe(
						on_next, observer.on_error, on_completed,
						scheduler
					)
				
				var on_completed = func():
					at_end[0] = true
					subscription.dispose()
					done.call()
				
				subscription.set_disposable(source.subscribe(
					on_next, observer.on_error, on_completed,
					scheduler
				))
			
			if sub_delay == null:
				start.call()
			else:
				subscription.set_disposable(sub_delay.subscribe(
					func(__): start.call(), observer.on_error, start
				))
			
			return CompositeDisposable.new([subscription, delays])
		
		return Observable.new(subscribe)
	
	return delay_with_mapper
