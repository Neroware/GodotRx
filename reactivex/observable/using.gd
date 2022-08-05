static func using_(
	resource_factory : Callable,
	observable_factory : Callable,
) -> Observable:
	
	var subscribe = func(
		observer : ObservableBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var disp : DisposableBase = Disposable.new()
		
		var resource = resource_factory.call()
		if resource is DisposableBase:
			disp = resource
		elif resource is GDRx.err.Error:
			var d = GDRx.obs.throw(resource).subscribe(observer, func(e): return, func(): return, scheduler)
			return CompositeDisposable.new([d, disp])
		
		var source = observable_factory.call(resource)
		
		return CompositeDisposable.new([
			source.subscribe(observer, func(e): return, func(): return, scheduler),
			disp
		])
	
	return Observable.new(subscribe)
