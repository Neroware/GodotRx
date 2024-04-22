## Merges the specified observable sequences into one observable
##    sequence by creating a tuple whenever all of the
##    observable sequences have produced an element at a corresponding
##    index.
## [br]
##    [b]Example:[/b]
##        [codeblock]
##        var res = GDRx.obs.zip([obs1, obs2])
##        [/codeblock]
## [br]
##    [b]Args:[/b]
## [br]
##       [code]args[/code] Observable sources to zip.
## [br][br]
##    [b]Returns:[/b]
## [br]
##        An observable sequence containing the result of combining
##        elements of the sources as tuple.
static func zip_(sources_) -> Observable:
	var sources : Array[Observable] = GDRx.util.unpack_arg(sources_)
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> CompositeDisposable:
		var n = sources.size()
		var queues = [] ; for __ in range(n): queues.append([])
		var lock = RLock.new()
		var is_completed = [] ; for __ in range(n): is_completed.append(false)
		
		var next_ = func(__ : int):
			var _guard = LockGuard.new(lock)
			if queues.all(func(x): return x.size() > 0):
				var res = RefValue.Null()
				if GDRx.try(func():
					var queued_values = [] ; for x in queues: queued_values.append(x.pop_front())
					res.v = Tuple.new(queued_values)
				) \
				.catch("Error", func(err):
					observer.on_error(err)
				) \
				.end_try_catch(): return
				
				observer.on_next(res.v)
				
				for idx in range(n):
					var queue = queues[idx]
					var done = is_completed[idx]
					if done and queue.size() == 0:
						observer.on_completed()
						break
		
		var completed = func(i : int):
			is_completed[i] = true
			if queues[i].size() == 0:
				observer.on_completed()
		
		var subscriptions : Array = [] ; for __ in range(n): subscriptions.append(null)
		
		var fun = func(i : int):
			var source : Observable = sources[i]
			
			var sad = SingleAssignmentDisposable.new()
			
			var on_next = func(x):
				queues[i].append(x)
				next_.call(i)
			
			sad.disposable = source.subscribe(
				on_next, observer.on_error, func(): completed.call(i), scheduler
			)
			subscriptions[i] = sad
		
		for idx in range(n):
			fun.call(idx)
		return CompositeDisposable.new(subscriptions)
	
	return Observable.new(subscribe)
