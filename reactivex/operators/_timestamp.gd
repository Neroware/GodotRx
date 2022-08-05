static func timestamp_(
	scheduler : SchedulerBase = null
) -> Callable:
	var timestamp = func(source : Observable) -> Observable:
		
		var factory = func(scheduler_ : SchedulerBase = null):
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = TimeoutScheduler.singleton()
			
			var mapper = func(value) -> Tuple:
				return Tuple.new([value, _scheduler.now()])
			
			return source.pipe1(GDRx.op.map(mapper))
		
		return GDRx.obs.defer(factory)
	
	return timestamp
