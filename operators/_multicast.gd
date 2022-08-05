static func multicast_(
	subject : SubjectBase = null,
	subject_factory = null,
	mapper = null
) -> Callable:
	
	var multicast = func(source : Observable) -> Observable:
		if subject_factory != null:
			
			var subscribe = func(
				observer : ObserverBase,
				scheduler : SchedulerBase = null
			) -> DisposableBase:
				assert(subject_factory is Callable)
				var connectable = source.pipe1(
					GDRx.op.multicast(subject_factory.call(scheduler))
				)
				assert(mapper is Callable)
				var subscription = mapper.call(connectable).subscribe(
					observer, func(e):return, func():return,
					scheduler
				)
				
				return CompositeDisposable.new([
					subscription, connectable.connect(scheduler)
				])
			
			return Observable.new(subscribe)
		
		if subject == null:
			push_error("multicast: Subject cannot be null")
		var ret = ConnectableObservable.new(source, subject)
		return ret
	
	return multicast
