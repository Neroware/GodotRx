static func from_callback(
	fun : Callable = func(args : Array, cb : Callable): return,
	mapper : Callable = func(args): return args
) -> Callable:
	
	var function = func(args : Array) -> Observable:
		var arguments = args
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var handler = func(args : Array):
				var results = mapper.call(args)
				if results is GDRx.err.Error:
					observer.on_error(results)
					return
				observer.on_next(results)
		
			fun.call(arguments, handler)
			return Disposable.new()
		
		return Observable.new(subscribe)
	
	return function
