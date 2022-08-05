static func concat_with_iterable_(sources : IterableBase) -> Observable:
	
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler = scheduler_ if scheduler_ != null else CurrentThreadScheduler.singleton()
		
		var subscription = SerialDisposable.new()
		var cancelable = SerialDisposable.new()
		var is_disposed = RefValue.Set(false)
		
		var action = func(scheduler : SchedulerBase, state = null, action_ = func(__, ___, ____): return):
			if is_disposed.v:
				return
			
			var on_completed = func():
				cancelable.set_disposable(_scheduler.schedule(action_.bind(action_)))
			
			var current = sources.next()
			if not current is Observable:
				if current is GDRx.err.Error:
					observer.on_error(current)
				else:
					observer.on_completed()
			else:
				var d = SingleAssignmentDisposable.new()
				subscription.set_disposable(d)
				d.set_disposable(current.subscribe(
					observer.on_next,
					observer.on_error,
					on_completed,
					scheduler_
				))
		action = action.bind(action)
		
		cancelable.set_disposable(_scheduler.schedule(action))
		
		var dispose = func():
			is_disposed.v = true
		
		return CompositeDisposable.new([subscription, cancelable, Disposable.new(dispose)])
	
	return Observable.new(subscribe)
