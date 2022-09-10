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
