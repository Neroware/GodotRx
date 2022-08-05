static func zip_(args : Array[Observable]) -> Callable:
	var _zip = func(source : Observable) -> Observable:
		return GDRx.obs.zip([source] + args)
	return _zip

static func zip_with_iterable_(seq : IterableBase) -> Callable:
	var zip_with_iterable = func(source : Observable) -> Observable:
		var first = source
		var second : IterableBase = seq
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		):
			var index = RefValue.Set(0)
			
			var on_next = func(left):
				var right = second.next()
				if right is GDRx.err.Error:
					observer.on_error(right)
				elif right is second.End:
					observer.on_completed()
				else:
					var result = Tuple.new([left, right])
					observer.on_next(result)
			
			return first.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return zip_with_iterable
