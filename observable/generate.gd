static func generate_(
	initial_state,
	condition : Callable = func(state) -> bool: return true,
	iterate : Callable = func(state): return state
) -> Observable:
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var scheduler_ : SchedulerBase = scheduler if scheduler != null else CurrentThreadScheduler.singleton()
		var first = RefValue.Set(true)
		var state = RefValue.Set(initial_state)
		var mad = MultipleAssignmentDisposable.new()
		
		var action = func(scheduler : SchedulerBase, state1, action_ : Callable):
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
			.catch("Exception", func(exception):
				observer.on_error(exception)
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
