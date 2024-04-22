## Converts a callback function to an observable sequence.
##    [br]
##    [b]Args:[/b]
##    [br]
##        [code]fun[/code] Function with a callback as the last argument to
##            convert to an Observable sequence.
##    [br]
##        [code]mapper[/code] [Optional] A mapper which takes the arguments
##            from the callback to produce a single item to yield on next.
##    [br][br]
##    [b]Returns:[/b]
##    [br]
##        A function, when executed with the required arguments minus
##        the callback, produces an Observable sequence with a single value of
##        the arguments to the callback as a list.
static func from_callback(
	fun : Callable = func(_args : Array, _cb : Callable): return,
	mapper = null
) -> Callable:
	
	var function = func(args : Array) -> Observable:
		var arguments = args
		
		var subscribe = func(
			observer : ObserverBase,
			_scheduler : SchedulerBase = null
		) -> DisposableBase:
			var handler = func(args : Array):
				var results = RefValue.Set(args)
				if mapper != null:
					if GDRx.try(func():
						results.v = mapper.call(args)
					) \
					.catch("Error", func(e):
						observer.on_error(e)
					).end_try_catch():
						return Disposable.new()
					observer.on_next(results.v)
				else:
					observer.on_next(results.v)
					observer.on_completed()
			
			fun.call(arguments, handler)
			return Disposable.new()
		
		return Observable.new(subscribe)
	
	return function
