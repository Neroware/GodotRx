static func to_dict_(
	key_mapper : Callable, 
	element_mapper : Callable = GDRx.basic.identity
) -> Callable:
	var to_dict = func(source : Observable) -> Observable:
#		"""Converts the observable sequence to a Map if it exists.
#
#		Args:
#			source: Source observable to convert.
#
#		Returns:
#			An observable sequence with a single value of a dictionary
#			containing the values from the observable sequence.
#		"""
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			
			var m = RefValue.Set({})
			
			var on_next = func(x):
				var key = RefValue.Null()
				if GDRx.try(func():
					key.v = key_mapper.call(x)
				) \
				.catch("Error", func(e):
					observer.on_error(e)
				) \
				.end_try_catch(): return
				
				var element = RefValue.Null()
				if GDRx.try(func():
					element.v = element_mapper.call(x)
				) \
				.catch("Error", func(e):
					observer.on_error(e)
				) \
				.end_try_catch(): return
				
				m.v[key.v] = element.v
			
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
