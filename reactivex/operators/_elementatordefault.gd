static func element_at_or_default_(
	index : int, has_default : bool = false, default_value = GDRx.util.GetNotSet()
) -> Callable:
	
	if index < 0:
		push_error("Index canot be lower than zero!")
		index = 0
	
	var element_at_or_default = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, scheduler : SchedulerBase = null
		) -> DisposableBase:
			var index_ = RefValue.Set(index)
			
			var on_next = func(x):
				var found = false
				source._lock.lock()
				if index_.v > 0:
					index_.v -= 1
				else:
					found = true
				source._lock.unlock()
				
				if found:
					observer.on_next(x)
					observer.on_completed()
			
			var on_completed = func():
				if not has_default:
					observer.on_error(GDRx.err.ArgumentOutOfRangeException.new())
				else:
					observer.on_next(default_value)
					observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.ne(subscribe)
	
	return element_at_or_default
