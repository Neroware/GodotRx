## Continues an observable sequence that is terminated by an
##    exception with the next observable sequence.
##    [br]
##    [b]Examples:[/b]
##        [codeblock]
##        var res = GDRx.obs.catch_with_iterable(GDRx.util.Iter([xs, ys, zs]))
##        [/codeblock]
##    [br]
##    [b]Args:[/b]
##    [br]
##        [code]sources[/code] an iterable of observables. Thus a generator is accepted.
##    [br][br]
##    [b]Returns:[/b]
##    [br]
##        An observable sequence containing elements from consecutive
##        source sequences until a source sequence terminates
##        successfully.
static func catch_with_iterable_(sources : IterableBase) -> Observable:
	
	var sources_ : IterableBase = sources.iter()
	
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler = scheduler_ if scheduler_ != null else CurrentThreadScheduler.singleton()
		
		var subscription = SerialDisposable.new()
		var cancelable = SerialDisposable.new()
		var last_exception = RefValue.Null()
		var is_disposed = RefValue.Set(false)
		
		var action = func(_scheduler : SchedulerBase, _state = null, action_ : Callable = func(__, ___, ____): return):
			var on_error = func(exn):
				last_exception.v = exn
				cancelable.disposable = _scheduler.schedule(action_.bind(action_))
			
			if is_disposed.v:
				return
			
			var current = RefValue.Null()
			if GDRx.try(func():
				current.v = sources_.next()
			) \
			.catch("Exception", func(ex):
				observer.on_error(ex)
			) \
			.end_try_catch():
				pass
			elif current.v is ItEnd:
				if last_exception.v != null:
					observer.on_error(last_exception.v)
				else:
					observer.on_completed()
			else:
				var d = SingleAssignmentDisposable.new()
				subscription.disposable = d
				d.disposable = current.v.subscribe(
					observer.on_next,
					on_error,
					observer.on_completed,
					scheduler_
				)
		action = action.bind(action)
		
		cancelable.disposable = _scheduler.schedule(action)
		
		var dispose = func():
			is_disposed.v = true
		
		return CompositeDisposable.new([subscription, cancelable, Disposable.new(dispose)])
	
	return Observable.new(subscribe)
