static func take_until_(
	other : Observable
) -> Callable:
	var obs = other
	
	var take_until = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_completed = func():
				observer.on_completed()
			
			return CompositeDisposable.new([
				source.subscribe(observer, func(e):return, func():return, scheduler),
				obs.subscribe(on_completed, observer.on_error, func():return, scheduler)
			])
		
		return Observable.new(subscribe)
	
	return take_until
