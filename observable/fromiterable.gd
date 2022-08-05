static func from_iterable_(
	iterable : IterableBase,
	scheduler : SchedulerBase = null
) -> Observable:
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler_ : SchedulerBase = null
	) -> DisposableBase:
		var _scheduler : SchedulerBase
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = CurrentThreadScheduler.singleton()
		
		var iterator = iterable
		var disposed = RefValue.Set(false)
		
		var action = func(__ : SchedulerBase, ___ = null):
			while not disposed.v:
				var value = iterable.next()
				if value is IterableBase.End:
					observer.on_completed()
					break
				elif value is GDRx.err.Error:
					observer.on_error(value)
					break
				else:
					observer.on_next(value)
		
		var dispose = func():
			disposed.v = true
		
		var disp = Disposable.new(dispose)
		return CompositeDisposable.new([_scheduler.schedule(action), disp])
	
	return Observable.new(subscribe)
