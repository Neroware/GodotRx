static func take_while_(
	predicate : Callable = GDRx.basic.default_condition,
	inclusive : bool = false
) -> Callable:
	var take_while = func(source : Observable) -> Observable:
#		"""Returns elements from an observable sequence as long as a
#		specified condition is true.
#
#		Example:
#			>>> take_while.call(source)
#
#		Args:
#			source: The source observable to take from.
#
#		Returns:
#			An observable sequence that contains the elements from the
#			input sequence that occur before the element at which the
#			test no longer passes.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var running = RefValue.Set(true)
			
			var on_next = func(value):
				if true:
					var __ = LockGuard.new(source.lock)
					if not running.v:
						return
					
					if GDRx.try(func():
						running.v = predicate.call(value)
					) \
					.catch("Error", func(err):
						observer.on_error(err)
					).end_try_catch(): return
				
				if running.v:
					observer.on_next(value)
				else:
					if inclusive:
						observer.on_next(value)
					observer.on_completed()
				
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return take_while

static func take_while_indexed_(
	predicate : Callable = GDRx.basic.default_condition,
	inclusive : bool = false
) -> Callable:
	var take_while_indexed = func(source : Observable) -> Observable:
#		"""Returns elements from an observable sequence as long as a
#		specified condition is true. The element's index is used in the
#		logic of the predicate function.
#
#		Example:
#			>>> take_while_indexed.call(source)
#
#		Args:
#			source: Source observable to take from.
#
#		Returns:
#			An observable sequence that contains the elements from the
#			input sequence that occur before the element at which the
#			test no longer passes.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var running = RefValue.Set(true)
			var i = RefValue.Set(0)
			
			var on_next = func(value):
				if true:
					var __ = LockGuard.new(source.lock)
					if not running.v:
						return
					
					if GDRx.try(func():
						running.v = predicate.call(value, i.v)
					) \
					.catch("Error", func(err):
						observer.on_error(err)
					).end_try_catch(): return
					else:
						i.v += 1
				
				if running.v:
					observer.on_next(value)
				else:
					if inclusive:
						observer.on_next(value)
					observer.on_completed()
				
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return take_while_indexed
