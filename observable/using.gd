## Constructs an observable sequence that depends on a resource
##    object, whose lifetime is tied to the resulting observable
##    sequence's lifetime.
## [br]
##    [b]Example:[/b]
##        [codeblock]
##        var res = GDRx.obs.using(func(): return AsyncSubject.new(), func(s): return s)
##        [/codeblock]
## [br]
##    [b]Args:[/b]
## [br]
##        [code]resource_factory[/code] Factory function to obtain a resource object.
## [br]
##        [code]observable_factory[/code] Factory function to obtain an observable
##            sequence that depends on the obtained resource.
## [br][br]
##
##    [b]Returns:[/b]
## [br]
##        An observable sequence whose lifetime controls the lifetime
##        of the dependent resource object.
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
		else:
			disp = Disposable.Cast(resource)
		
		var source = observable_factory.call(resource)
		
		return CompositeDisposable.new([
			source.subscribe(observer, func(e): return, func(): return, scheduler),
			disp
		])
	
	return Observable.new(subscribe)
