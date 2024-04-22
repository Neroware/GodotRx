## Represents a Godot coroutine as an observable sequence
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
		
		var action = func(_scheduler : SchedulerBase, _state = null):
			var res = RefValue.Null()
			
			if GDRx.try(func():
				# WARNING! This await is not redundant as it seems.
				# At this point we do not know if 'coroutine' really is a 
				# coroutine but either way should this code work! If 'coroutine'
				# was a member function Godot would throw an error telling us
				# that this is, in fact, a coroutine if it contains an 'await'.
				@warning_ignore("redundant_await")
				res.v = await coroutine.call()
				observer.on_next(res.v)
				observer.on_completed()
			) \
			.catch("Error", func(e):
				observer.on_error(e)
			) \
			.end_try_catch(): return
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)
