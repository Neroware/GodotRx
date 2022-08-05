static func never_() -> Observable:
	
	var subscribe = func(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase:
		return Disposable.new()
	
	return Observable.new(subscribe)
