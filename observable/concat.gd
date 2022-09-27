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
				cancelable.disposable = _scheduler.schedule(action_.bind(action_))
			
			var current_ref = RefValue.Null()
			var failed = GDRx.try(func():
				current_ref.v = sources.next()
			) \
			.catch("Exception", func(ex):
				observer.on_error(ex)
			) \
			.end_try_catch()
			var current = current_ref.v
			if failed:
				pass
			elif current is sources.End:
				observer.on_completed()
			else:
				var d = SingleAssignmentDisposable.new()
				subscription.disposable = d
				d.disposable = current.subscribe(
					observer.on_next,
					observer.on_error,
					on_completed,
					scheduler_
				)
		action = action.bind(action)
		
		cancelable.disposable = _scheduler.schedule(action)
		
		var dispose = func():
			is_disposed.v = true
		
		return CompositeDisposable.new([subscription, cancelable, Disposable.new(dispose)])
	
	return Observable.new(subscribe)
