static func some_(
	predicate = null
) -> Callable:
	var some = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_next = func(__):
				observer.on_next(true)
				observer.on_completed()
			
			var on_error = func():
				observer.on_next(false)
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_error,
				scheduler
			)
		
		if predicate != null:
			var predicate_ : Callable = predicate
			return source.pipe2(
				GDRx.op.filter(predicate_),
				some_()
			)
		
		return Observable.new(subscribe)
	
	return some
