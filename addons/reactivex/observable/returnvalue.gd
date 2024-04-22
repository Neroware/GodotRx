## Returns an observable sequence that contains a single element,
##    using the specified scheduler to send out observer messages.
##    There is an alias called [method __GDRx_Singleton__.just].
## [br]
##    [b]Examples:[/b]
##        [codeblock]
##        var res = GDRx.obs.return_value(42)
##        var res = GDRx.obs.return_value(42, GDRx.TimeoutScheduler_)
##        var res = GDRx.just(42)
##        [/codeblock]
## [br]
##    [b]Args:[/b]
## [br]
##        [code]value[/code] Single element in the resulting observable sequence.
## [br][br]
##    [b]Returns:[/b]
## [br]
##        An observable sequence containing the single specified
##        element.
static func return_value_(value, scheduler : SchedulerBase = null) -> Observable:
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = CurrentThreadScheduler.singleton()
		
		var action = func(_scheduler : SchedulerBase, _state = null):
			observer.on_next(value)
			observer.on_completed()
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)

static func from_callable_(supplier : Callable, scheduler : SchedulerBase = null) -> Observable:
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = CurrentThreadScheduler.singleton()
		
		var action = func(__ : SchedulerBase, ___ = null):
			GDRx.try(func():
				observer.on_next(supplier.call())
				observer.on_completed()
			) \
			.catch("Error", func(e):
				observer.on_error(e)
			) \
			.end_try_catch()
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)
