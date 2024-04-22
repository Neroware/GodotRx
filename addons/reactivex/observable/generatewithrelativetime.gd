## Generates an observable sequence by iterating a state from an
##    initial state until the condition fails.
##    [br]
##    [b]Example:[/b]
##        [codeblock]
##        var res = GDRx.obs.generate_with_relative_time(
##            0, func(x): return true, func(x): return x + 1, func(x): return 0.5
##        )
##        [/codeblock]
##    [br]
##    [b]Args:[/b]
##    [br]
##        [code]initial_state[/code] Initial state.
##    [br]
##        [code]condition[/code] Condition to terminate generation (upon returning
##            false).
##    [br]
##        [code]iterate[/code] Iteration step function.
##    [br]
##        [code]time_mapper[/code] Time mapper function to control the speed of
##            values being produced each iteration, returning relative
##            times, i.e. either floats denoting seconds or instances of
##            timedelta.
##    [br][br]
##    [b]Returns:[/b]
##    [br]
##        The generated sequence.
static func generate_with_relative_time_(
	initial_state,
	condition : Callable = GDRx.basic.default_condition,
	iterate : Callable = GDRx.basic.identity,
	time_mapper : Callable = func(_state) -> float: return 1.0
) -> Observable:
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var _scheduler : SchedulerBase = scheduler if scheduler != null else SceneTreeTimeoutScheduler.singleton()
		var mad = MultipleAssignmentDisposable.new()
		var state = RefValue.Set(initial_state)
		var has_result = RefValue.Set(false)
		var result = RefValue.Null()
		var first = RefValue.Set(true)
		var time = RefValue.Null()
		
		var action = func(scheduler : SchedulerBase, __, action_ : Callable):
			if has_result.v:
				observer.on_next(result.v)
			
			if GDRx.try(func():
				if first.v:
					first.v = false
				else:
					state.v = iterate.call(state.v)
				
				has_result.v = condition.call(state.v)
				
				if has_result.v:
					result.v = state.v
					time.v = time_mapper.call(state.v)
			) \
			.catch("Error", func(e):
				observer.on_error(e)
			) \
			.end_try_catch(): return
			
			if has_result.v:
				if GDRx.assert_(time.v != null): return
				mad.disposable = scheduler.scheduler_relative(time.v, action_.bind(action_))
			else:
				observer.on_completed()
		
		mad.disposable = _scheduler.schedule_relative(0, action.bind(action))
		return mad
	
	return Observable.new(subscribe)
