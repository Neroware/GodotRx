func distinct_until_changed_(
	key_mapper : Callable = GDRx.basic.identity,
	comparer : Callable = GDRx.basic.default_comparer
) -> Callable:
	
	var key_mapper_ = key_mapper
	var comparer_ = comparer
	
	var distinct_until_changed = func(source : Observable) -> Observable:
		"""Returns an observable sequence that contains only distinct
		contiguous elements according to the key_mapper and the
		comparer.

		Examples:
			>>> op = GDRx.op.distinct_until_changed()
			>>> op = GDRx.op.distinct_until_changed(func(x): return x.id)
			>>> op = GDRx.op.distinct_until_changed(func(x): return x.id, func(x, y): return x == y)

		Args:
			key_mapper: [Optional] A function to compute the comparison
				key for each element. If not provided, it projects the
				value.
			comparer: [Optional] Equality comparer for computed key
				values. If not provided, defaults to an equality
				comparer function.

		Returns:
			An observable sequence only containing the distinct
			contiguous elements, based on a computed key value, from
			the source sequence.
		"""
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
