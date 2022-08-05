static func subscribe_on_(scheduler : SchedulerBase) -> Callable:
	
	var subscribe_on = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, __ : SchedulerBase = null
		) -> DisposableBase:
			var m = SingleAssignmentDisposable.new()
			var d = SerialDisposable.new()
			d.set_disposable(m)
			
			var action = func(scheduler : SchedulerBase, state = null):
				d.set_disposable(ScheduledDisposable.new(
					scheduler, source.subscribe(observer)
				))
			
			m.set_disposable(scheduler.schedulde(action))
			return d
		
		return Observable.new(subscribe)
	
	return subscribe_on
