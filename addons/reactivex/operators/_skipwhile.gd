static func skip_while_(predicate : Callable) -> Callable:
	var skip_while = func(source : Observable) -> Observable:
		
#		"""Bypasses elements in an observable sequence as long as a
#		specified condition is true and then returns the remaining
#		elements. The element's index is used in the logic of the
#		predicate function.
#
#		Example:
#			>>> skip_while.call(source)
#
#		Args:
#			source: The source observable to skip elements from.
#
#		Returns:
#			An observable sequence that contains the elements from the
#			input sequence starting at the first element in the linear
#			series that does not pass the test specified by predicate.
#		"""
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var running = RefValue.Set(false)
			
			var on_next = func(value):
				if not running.v:
					if GDRx.try(func():
						running.v = not predicate.call(value)
					) \
					.catch("Error", func(exn):
						observer.on_error(exn)
					) \
					.end_try_catch(): return
				
				if running.v:
					observer.on_next(value)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return skip_while

func skip_while_indexed_(predicate : Callable) -> Callable:
	var indexer = func(x, i : int) -> Tuple:
		return Tuple.new([x, i])
	
	var skipper = func(x : Tuple) -> bool:
		return predicate.call(x.at(0), x.at(1))
	
	var mapper = func(x : Tuple):
		return x.at(0)
	
	return GDRx.pipe.compose3(
		GDRx.op.map_indexed(indexer),
		GDRx.op.skip_while(skipper),
		GDRx.op.map(mapper)
	)
