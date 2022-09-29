## Represents a Godot [Signal] as an observable sequence
static func from_godot_coroutine_(
	fun : Callable,
	bindings : Array = [],
	scheduler : SchedulerBase = null
) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		scheduler_ : SchedulerBase = null
	) -> DisposableBase:
		var coroutine : Callable = fun
		var n_bind = bindings.size()
		for argi in range(n_bind):
			coroutine = coroutine.bind(bindings[n_bind - argi - 1])
		
		var _scheduler
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = CurrentThreadScheduler.singleton()
		
		var action = func(scheduler : SchedulerBase, state = null):
			var res = RefValue.Null()
			
			if GDRx.try(func():
				res.v = await coroutine.call()
				observer.on_next(res.v)
				observer.on_completed()
			) \
			.catch("Exception", func(e):
				observer.on_error(e)
			) \
			.end_try_catch(): return
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)
