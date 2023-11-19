## Wait for observables to complete and then combine last values
##    they emitted into a tuple. Whenever any of that observables completes
##    without emitting any value, result sequence will complete at that moment as well.
##    [br][br]
##    [b]Examples:[/b]
##    [codeblock]
##    var obs = GDRx.obs.fork_join([obs1, obs2, obs3])
##    [/codeblock]
##    [br]
##    [b]Returns:[/b]
##    [br]
##        An observable sequence containing the result of combining last element from
##        each source in given sequence.
static func fork_join_(sources_) -> Observable:
	var sources : Array[Observable] = GDRx.util.unpack_arg(sources_)
	var parent = sources[0]
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var n = sources.size()
		var values = [] ; for __ in range(n): values.append(null)
		var is_done = [] ; for __ in range(n): values.append(false)
		var has_value = [] ; for __ in range(n): values.append(false)
		
		var done = func(i : int):
			is_done[i] = true
			
			if not has_value[i]:
				observer.on_completed()
				return
			
			if is_done.all(func(elem): return elem):
				if has_value.all(func(elem): return elem):
					observer.on_next(Tuple.new(values))
					observer.on_completed()
				else:
					observer.on_completed()
		
		var subscriptions : Array[SingleAssignmentDisposable] = []
		for __ in range(n): subscriptions.append(null)
		
		var _subscribe = func(i : int):
			subscriptions[i] = SingleAssignmentDisposable.new()
			
			var on_next = func(value):
				var __ = LockGuard.new(parent.lock)
				values[i] = value
				has_value[i] = true
			
			var on_completed = func():
				var __ = LockGuard.new(parent.lock)
				done.call(i)
			
			subscriptions[i].disposable = sources[i].subscribe(
				on_next, observer.on_error, on_completed, scheduler
			)
		
		for i in range(n):
			_subscribe.call(i)
		return CompositeDisposable.new(subscriptions)
	
	return Observable.new(subscribe)
