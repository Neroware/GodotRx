static func catch_handler(
	source : Observable,
	handler : Callable
) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var d1 = SingleAssignmentDisposable.new()
		var subscription = SerialDisposable.new()
		
		subscription.set_disposable(d1)
		
		var on_error = func(exception):
			var result = handler.call(exception, source)
			if result is GDRx.err.Error:
				observer.on_error(result)
				return
			
			var d = SingleAssignmentDisposable.new()
			subscription.set_disposable(d)
			d.set_disposable(result.subscribe(
				observer, func(e):return, func():return, scheduler
			))
		
		d1.set_disposable(source.subscribe(
			observer.on_next, on_error, observer.on_completed,
			scheduler
		))
		return subscription
	
	return Observable.new(subscribe)

static func catch_(handler) -> Callable:
	var catch = func(source : Observable) -> Observable:
		"""Continues an observable sequence that is terminated by an
		exception with the next observable sequence.

		Examples:
			>>> var op = catch.call(ys)
			>>> var op = catch.call(func(ex, src): return ys(ex))

		Args:
			handler: Second observable sequence used to produce
				results when an error occurred in the first sequence, or an
				exception handler function that returns an observable sequence
				given the error and source observable that occurred in the
				first sequence.

		Returns:
			An observable sequence containing the first sequence's
			elements, followed by the elements of the handler sequence
			in case an exception occurred.
		"""
		if handler is Callable:
			return catch_handler(source, handler)
		else:
			return GDRx.obs.catch_with_iterable(GDRx.util.Iter([source, handler]))
	
	return catch
