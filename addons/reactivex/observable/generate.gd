static func generate_(
	initial_state,
	condition : Callable = GDRx.basic.default_condition,
	iterate : Callable = GDRx.basic.identity
) -> Observable:
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var scheduler_ : SchedulerBase = scheduler if scheduler != null else CurrentThreadScheduler.singleton()
		var first = RefValue.Set(true)
		var state = RefValue.Set(initial_state)
		var mad = MultipleAssignmentDisposable.new()
		
		var action = func(scheduler : SchedulerBase, _state, action_ : Callable):
			var has_result = RefValue.Set(false)
			var result = RefValue.Null()
			
			if GDRx.try(func():
				if first.v:
					first.v = false
				else:
					state.v = iterate.call(state.v)
				
				has_result.v = condition.call(state.v)
				if has_result.v:
					result.v = state.v
			) \
			.catch("Error", func(err):
				observer.on_error(err)
			) \
			.end_try_catch(): return
			
			if has_result.v:
				observer.on_next(result.v)
				mad.disposable = scheduler.schedule(action_.bind(action_))
			else:
				observer.on_completed()
		
		mad.disposable = scheduler_.schedule(action.bind(action))
		return mad
	
	return Observable.new(subscribe)
