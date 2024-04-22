## Converts the function into an asynchronous function. Each
##    invocation of the resulting asynchronous function causes an
##    invocation of the original synchronous function on the specified
##    scheduler.
## [br]
##    [b]Examples:[/b]
##        [codeblock]
##        var res = GDRx.obs.to_async(func(x, y): return x + y).call(4, 3)
##        var res = GDRx.obs.to_async(func(x, y): return x + y, GDRx.TimeoutScheduler_).call(4, 3)
##        var res = GDRx.obs.to_async(func(x): print(x), GDRx.TimeoutScheduler_).call("hello")
##        [/codeblock]
## [br]
##    [b]Args:[/b]
## [br]
##        [code]func[/code] Function to convert to an asynchronous function.
## [br]
##        [code]scheduler[/code] [Optional] Scheduler to run the function on. If not
##            specified, defaults to GDRx.TimeoutScheduler_.
## [br][br]
##    [b]Returns:[/b]
## [br]
##        Aynchronous function.
static func to_async_(
	fun : Callable, scheduler : SchedulerBase = null
) -> Callable:
	
	var _scheduler = scheduler if scheduler != null else SceneTreeTimeoutScheduler.singleton()
	
	var wrapper = func(args : Array) -> Observable:
		var subject = AsyncSubject.new()
		
		var action = func(_scheduler : SchedulerBase, _state = null):
			var result = RefValue.Null()
			if GDRx.try(func():
				result.v = fun.call(args)
			) \
			.catch("Error", func(err):
				subject.on_error(err)
			) \
			.end_try_catch(): return
			
			subject.on_next(result.v)
			subject.on_completed()
		
		_scheduler.schedule(action)
		return subject.as_observable()
	
	return wrapper
