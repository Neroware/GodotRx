static func element_at_or_default_(
	index : int, has_default : bool = false, default_value = GDRx.util.GetNotSet()
) -> Callable:
	
	if index < 0:
		ArgumentOutOfRangeError.new(
			"Argument cannot be lower than zero!").throw()
		index = 0
	
	var element_at_or_default = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, scheduler : SchedulerBase = null
		) -> DisposableBase:
			var index_ = RefValue.Set(index)
			
			var on_next = func(x):
				var found = false
				if true:
					var __ = LockGuard.new(source.lock)
					if index_.v > 0:
						index_.v -= 1
					else:
						found = true
				
				if found:
					observer.on_next(x)
					observer.on_completed()
			
			var on_completed = func():
				if not has_default:
					observer.on_error(ArgumentOutOfRangeError.new())
				else:
					observer.on_next(default_value)
					observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return element_at_or_default
