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
		var disp = RefValue.Set(Disposable.new())
		
		var d = RefValue.Null()
		var source = RefValue.Null()
		if GDRx.try(func():
			var resource = resource_factory.call()
			if resource is DisposableBase:
				disp.v = resource
			
			source.v = observable_factory.call(resource)
		) \
		.catch("Error", func(err):
			d.v = GDRx.obs.throw(err).subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, scheduler)
		) \
		.end_try_catch():
			return CompositeDisposable.new([d.v, disp.v])
		
		return CompositeDisposable.new([
			source.v.subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, scheduler),
			disp.v
		])
	
	return Observable.new(subscribe)
