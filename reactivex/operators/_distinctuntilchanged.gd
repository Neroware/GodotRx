func distinct_until_changed_(
	key_mapper : Callable = GDRx.basic.identity,
	comparer : Callable = GDRx.basic.default_comparer
) -> Callable:
	
	var key_mapper_ = key_mapper
	var comparer_ = comparer
	
	var distinct_until_changed = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var has_current_key = RefValue.Set(false)
			var current_key = RefValue.Null()
			
			var on_next = func(value):
				var comparer_equals = false
				var key = key_mapper_.call(value)
				if key is GDRx.err.Error:
					observer.on_error(key)
					return
				
				if has_current_key.v:
					comparer_equals = comparer_.call(current_key.v, key)
					if comparer_equals is GDRx.err.Error:
						observer.on_error(comparer_equals)
						return
				
				if not has_current_key.v or not comparer_equals:
					has_current_key.v = true
					current_key.v = key
					observer.on_next(value)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return distinct_until_changed
