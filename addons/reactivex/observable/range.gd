const MAX_SIZE = 9223372036854775807

## Generates an observable sequence of integral numbers within a
##    specified range, using the specified scheduler to send out observer
##    messages.
## [br]
##    [b]Examples:[/b]
##        [codeblock]
##        var res = GDRx.obs.range(10)
##        var res = GDRx.obs.range(0, 10)
##        var res = GDRx.obs.range(0, 10, 1)
##        [/codeblock]
## [br]
##    [b]Args:[/b]
## [br]
##        [code]start[/code] The value of the first integer in the sequence.
## [br]
##        [code]stop[/code] [Optional] Generate number up to (exclusive) the stop
##            value. Default is `sys.maxsize`.
## [br]
##        [code]step[/code] [Optional] The step to be used (default is 1).
## [br]
##        [code]scheduler[/code] The scheduler to schedule the values on.
## [br][br]
##    [b]Returns:[/b]
## [br]
##        An observable sequence that contains a range of sequential
##        integral numbers.
static func range_(
	start : int,
	stop = null,
	step = null,
	scheduler : SchedulerBase = null
) -> Observable:
	
	@warning_ignore("incompatible_ternary")
	var _stop : int = MAX_SIZE if stop == null else stop
	@warning_ignore("incompatible_ternary")
	var _step : int = 1 if step == null else step
	
	var range_t : Array
	if step == null and stop == null:
		range_t = range(start)
	elif step == null:
		range_t = range(start, _stop)
	else:
		range_t = range(start, _stop, _step)
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler_ : SchedulerBase = null
	) -> DisposableBase:
		var _scheduler : SchedulerBase = null
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = CurrentThreadScheduler.singleton()
		var sd = MultipleAssignmentDisposable.new()
		
		var action = func(
			_scheduler : SchedulerBase,
			iterator : Iterator,
			action_ : Callable
		):
			if GDRx.assert_(iterator != null): return
			var item = iterator.next()
			if item is ItEnd:
				observer.on_completed()
			else:
				observer.on_next(item)
				sd.disposable = _scheduler.schedule(
					action_.bind(action_), iterator
				)
		
		sd.disposable = _scheduler.schedule(action.bind(action), GDRx.util.Iter(range_t).iter())
		return sd
	
	return Observable.new(subscribe)
