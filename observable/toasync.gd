## Converts the function into an asynchronous function. Each
##    invocation of the resulting asynchronous function causes an
##    invocation of the original synchronous function on the specified
##    scheduler.
## [br]
##    Examples:
##        [codeblock]
##        var res = GDRx.obs.to_async(func(x, y): return x + y).call(4, 3)
##        var res = GDRx.obs.to_async(func(x, y): return x + y, GDRx.TimeoutScheduler_).call(4, 3)
##        var res = GDRx.obs.to_async(func(x): print(x), GDRx.TimeoutScheduler_).call("hello")
##        [/codeblock]
## [br]
##    Args:
## [br]
##        -> func: Function to convert to an asynchronous function.
## [br]
##        -> scheduler: [Optional] Scheduler to run the function on. If not
##            specified, defaults to GDRx.TimeoutScheduler_.
## [br][br]
##    Returns:
## [br]
##        Aynchronous function.
static func to_async_(
	fun : Callable, scheduler : SchedulerBase = null
) -> Callable:
	
	var _scheduler = scheduler if scheduler != null else TimeoutScheduler.singleton()
	
	var wrapper = func(args : Array) -> Observable:
		var subject = AsyncSubject.new()
		
		var action = func(scheduler : SchedulerBase, state = null):
			var result = fun.call(args)
			if result is GDRx.err.Error:
				subject.observer().on_error(result)
				return
			
			subject.observer().on_next(result)
			subject.observer().on_completed()
		
		_scheduler.schedule(action)
		return subject.observable().pipe1(GDRx.op.as_observable())
	
	return wrapper
