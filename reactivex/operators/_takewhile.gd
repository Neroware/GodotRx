static func take_while_(
	predicate : Callable = func(value) -> bool: return true,
	inclusive : bool = false
) -> Callable:
	var take_while = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var running = RefValue.Set(true)
			
			var on_next = func(value):
				source._lock.lock()
				if not running.v:
					source._lock.unlock()
					return
				
				running.v = predicate.call(value)
				if not running.v is bool:
					observer.on_error(running.v)
					source._lock.unlock()
					return
				source._lock.unlock()
				
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
	predicate : Callable = func(value, index) -> bool: return true,
	inclusive : bool = false
) -> Callable:
	var take_while_indexed = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var running = RefValue.Set(true)
			var i = RefValue.Set(0)
			
			var on_next = func(value):
				source._lock.lock()
				if not running.v:
					source._lock.unlock()
					return
				
				running.v = predicate.call(value, i.v)
				if not running.v is bool:
					observer.on_error(running.v)
					source._lock.unlock()
					return
				i.v += 1
				source._lock.unlock()
				
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
