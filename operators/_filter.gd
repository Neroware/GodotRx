static func filter_(predicate : Callable = func(x): return true) -> Callable:
	var filter = func(source : Observable) -> Observable:
		"""Partially applied filter operator.

		Filters the elements of an observable sequence based on a
		predicate.

		Example:
			>>> filter.call(source)

		Args:
			source: Source observable to filter.

		Returns:
			A filtered observable sequence.
		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_next = func(value):
				var should_run = RefValue.Set(true)
				if GDRx.try(func():
					should_run.v = predicate.call(value)
				) \
				.catch("Exception", func(ex):
					observer.on_error(ex)
				) \
				.end_try_catch(): return
				
				if should_run.v:
					observer.on_next(value)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return filter

static func filter_indexed_(predicate : Callable = func(x, index): return true) -> Callable:
	var filter_indexed = func(source : Observable) -> Observable:
		"""Partially applied indexed filter operator.

		Filters the elements of an observable sequence based on a
		predicate by incorporating the element's index.

		Example:
			>>> filter_indexed.call(source)

		Args:
			source: Source observable to filter.

		Returns:
			A filtered observable sequence.
		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			
			var count = RefValue.Set(0)
			
			var on_next = func(value):
				var should_run = predicate.call(value, count.v)
				if not should_run is bool:
					observer.on_error(GDRx.err.BadPredicateError.new())
					return
				count.v += 1
				if should_run:
					observer.on_next(value)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return filter_indexed
