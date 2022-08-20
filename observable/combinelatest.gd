## Merges the specified observable sequences into one observable
##    sequence by creating a tuple whenever any of the
##    observable sequences produces an element.
##    [br]
##    Examples:
##    [codeblock]
##        var obs = GDRx.obs.combine_latest([obs1, obs2, obs3])
##    [/codeblock]
##    [br]
##    Returns:
##    [br]
##        An observable sequence containing the result of combining
##        elements of the sources into a tuple.
static func combine_latest_(sources : Array[Observable]) -> Observable:
	var parent = sources[0]
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> CompositeDisposable:
		
		var n = sources.size()
		var has_value = [] ; for __ in range(n): has_value.append(false)
		var has_value_all = [false]
		var is_done = [] ; for __ in range(n): is_done.append(false)
		var values = [] ; for __ in range(n): values.append(null)
		
		var _next = func(i):
			has_value[i] = true
			
			if has_value_all[0] or has_value.all(func(elem): return elem):
				var res = Tuple.new(values)
				observer.on_next(res)
			
			# Would be way shorter with list arithmetic!
			# elif all([x for j, x in enumerate(is_done) if j != i]):
			else:
				var completed = true
				var j = 0
				for x in is_done:
					if j == i:
						j += 1
						continue
					if not x:
						completed = false
						break
					j += 1
				if completed:
					observer.on_completed()
			
			has_value_all[0] = has_value.all(func(elem): return elem)
		
		var done = func(i):
			is_done[i] = true
			if is_done.all(func(elem): return elem):
				observer.on_completed()
		
		var subscriptions = [] ; for __ in range(n): subscriptions.append(null)
		var fun = func(i):
			subscriptions[i] = SingleAssignmentDisposable.new()
			
			var on_next = func(x):
				parent._lock.lock()
				values[i] = x
				_next.call(i)
				parent._lock.unlock()
			
			var on_completed = func():
				parent._lock.lock()
				done.call(i)
				parent._lock.unlock()
			
			var subscription = subscriptions[i]
			assert(subscription != null)
			subscription.set_disposable(sources[i].subscribe(
				on_next, observer.on_error,
				on_completed, scheduler
			))
		
		for idx in range(n):
			fun.call(idx)
		return CompositeDisposable.new(subscriptions)
	
	return Observable.new(subscribe)
