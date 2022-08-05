const MAX_SIZE = 9223372036854775807

static func range_(
	start : int,
	stop = null,
	step = null,
	scheduler : SchedulerBase = null
) -> Observable:
	
	var _stop : int = MAX_SIZE if stop == null else stop
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
			scheduler : SchedulerBase,
			iterator : IterableBase,
			action_ : Callable
		):
			assert(iterator != null)
			var item = iterator.next()
			if item is iterator.End:
				observer.on_completed()
			else:
				observer.on_next(item)
				sd.set_disposable(_scheduler.schedule(
					action_.bind(action_), iterator
				))
		
		sd.set_disposable(_scheduler.schedule(action.bind(action), GDRx.util.Iter(range_t)))
		return sd
	
	return Observable.new(subscribe)
