## Continues an observable sequence that is terminated normally or
##    by an error with the next observable sequence.
## [br][br]
##    [b]Examples:[/b]
##        [codeblock]
##        var res = GDRx.obs.on_error_resume_next([xs, ys, zs])
##        [/codeblock]
## [br][br]
##    [b]Returns:[/b]
## [br]
##        An observable sequence that concatenates the source sequences,
##        even if a sequence terminates exceptionally.
static func on_error_resume_next_(sources) -> Observable:
	
	var sources_ : Iterator = GDRx.iter(sources)
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var scheduler_ : SchedulerBase = scheduler if scheduler != null else CurrentThreadScheduler.singleton()
		
		var subscription = SerialDisposable.new()
		var cancelable = SerialDisposable.new()
		
		var action = func(
			scheduler : SchedulerBase,
			state = null,
			action_ : Callable = func(__, ___, ____): return
		):
			var source = sources_.next()
			if source is ItEnd:
				observer.on_completed()
				return
			
			source = source.call() if source is Callable else source
			var current : Observable = source
			
			var d = SingleAssignmentDisposable.new()
			subscription.disposable = d
			
			var on_resume = func(state = null):
				scheduler.schedule(action_.bind(action_), state)
			
			d.disposable = current.subscribe(
				observer.on_next, on_resume,
				on_resume, scheduler
			)
		
		cancelable.disposable = scheduler_.schedule(action.bind(action))
		return CompositeDisposable.new([subscription, cancelable])
	
	return Observable.new(subscribe)
