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
			var has_result = false
			var result = null
			
			if first.v:
				first.v = false
			else:
				state.v = iterate.call(state.v)
			
			has_result = condition.call(state.v)
			if has_result:
				result = state.v
			
			if result is GDRx.err.Error:
				observer.on_error(result)
				return
			
			if has_result:
				observer.on_next(result)
				mad.set_disposable(scheduler.schedule(action_.bind(action_)))
			else:
				observer.on_completed()
		
		mad.set_disposable(scheduler_.schedule(action.bind(action)))
		return mad
	
	return Observable.new(subscribe)
