## Returns an observable sequence that invokes the specified factory
##    function whenever a new observer subscribes.
##    [br]
##    [b]Example:[/b]
##        [codeblock]
##        var res = GDRx.obs.defer(func(scheduler): return GDRx.of([1, 2, 3]))
##        [/codeblock]
##    [br]
##    [b]Args:[/b]
##    [br]
##        [code]observable_factory[/code] Observable factory function to invoke for
##        each observer that subscribes to the resulting sequence. The
##        factory takes a single argument, the scheduler used.
##    [br][br]
##    [b]Returns:[/b]
##    [br]
##        An observable sequence whose observers trigger an invocation
##        of the given observable factory function.
static func defer_(factory : Callable = GDRx.basic.default_factory) -> Observable:
	
	var subscribe = func(
		observer : ObserverBase, 
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		
		var result = RefValue.Null()
		var failed = RefValue.Null()
		if GDRx.try(func():
			result.v = factory.call(scheduler if scheduler != null else ImmediateScheduler.singleton())
		) \
		.catch("Error", func(err):
			failed.v = GDRx.obs.throw(err).subscribe(observer)
		) \
		.end_try_catch():
			return failed.v
		return result.v.subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, scheduler)
	
	return Observable.new(subscribe)
