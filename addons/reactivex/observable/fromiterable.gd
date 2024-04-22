## Converts an iterable to an observable sequence.
##    [br]
##    [b]Example:[/b]
##        [codeblock]
##        var res = GDRx.obs.from_iterable(GDRx.iter([1,2,3]))
##        var res = GDRx.obs.from_iterable(GDRx.util.Infinite())
##        [/codeblock]
##    [br]
##    [b]Args:[/b]
##    [br]
##        [code]iterable[/code] An instance of [IterableBase]
##    [br]
##        [code]scheduler[/code] An optional scheduler to schedule the values on.
##    [br][br]
##    [b]Returns:[/b]
##    [br]
##        The observable sequence whose elements are pulled from the
##        given iterable sequence.
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
		
		var iterator = iterable.iter()
		var disposed = RefValue.Set(false)
		
		var action = func(__ : SchedulerBase, ___ = null):
			GDRx.try(func():
				while not disposed.v:
					var value = iterator.next()
					if value is ItEnd:
						observer.on_completed()
					else:
						observer.on_next(value)
			) \
			.catch("Error", func(error):
				observer.on_error(error)
			) \
			.end_try_catch()
		
		var dispose = func():
			disposed.v = true
		
		var disp = Disposable.new(dispose)
		return CompositeDisposable.new([_scheduler.schedule(action), disp])
	
	return Observable.new(subscribe)
