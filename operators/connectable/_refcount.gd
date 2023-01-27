static func ref_count_() -> Callable:
	
	var connectable_subscription = RefValue.Null()
	var count = RefValue.Set(0)
	
	var ref_count = func(source : ConnectableObservable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			
			count.v += 1
			var should_connect = count.v == 1
			var subscription = source.subscribe(
				observer, GDRx.basic.noop, GDRx.basic.noop,
				scheduler
			)
			if should_connect:
				connectable_subscription.v = source.connect_observable(scheduler)
			
			var dispose = func():
				subscription.dispose()
				count.v -= 1
				if count.v <= 0 and connectable_subscription.v != null:
					connectable_subscription.v.dispose()
			
			return Disposable.new(dispose)
		
		return Observable.new(subscribe)
	
	return ref_count
