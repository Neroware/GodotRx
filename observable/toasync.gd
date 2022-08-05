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
