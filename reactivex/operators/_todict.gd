static func to_dict_(
	key_mapper : Callable, 
	element_mapper : Callable = func(v): return v
) -> Callable:
	var to_dict = func(source : Observable) -> Observable:
		
		var m = RefValue.Set({})
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			
			var on_next = func(x):
				var key = key_mapper.call(x)
				if key is GDRx.err.Error:
					observer.on_error(key)
					return
				
				var element = element_mapper.call(x)
				if key is GDRx.err.Error:
					observer.on_error(key)
					return
				
				m.v[key] = element
			
			var on_completed = func():
				observer.on_next.call(m.v)
				m.v = {}
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return to_dict
