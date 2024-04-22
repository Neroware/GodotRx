static func observable_timer_date(duetime : float, scheduler : SchedulerBase = null) -> Observable:
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler : SchedulerBase = null
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = SceneTreeTimeoutScheduler.singleton()
		
		var action = func(_scheduler : SchedulerBase, _state):
			observer.on_next(0)
			observer.on_completed()
		
		return _scheduler.schedule_absolute(duetime, action)
	
	return Observable.new(subscribe)

static func observable_timer_duetime_and_period(duetime : float, time_absolute : bool, period : float, scheduler : SchedulerBase = null) -> Observable:
	var duetime_ref = RefValue.Set(duetime)
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler : SchedulerBase = null
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = SceneTreeTimeoutScheduler.singleton()
		
		if not time_absolute:
			duetime_ref.v = _scheduler.now() + duetime_ref.v
		
		var p = max(0.0, period)
		var mad = MultipleAssignmentDisposable.new()
		var dt = RefValue.Set(duetime_ref.v)
		var count = RefValue.Set(0)
		
		var action = func(scheduler : SchedulerBase, _state, action_):
			if p > 0.0:
				var now = scheduler.now()
				dt.v = dt.v + p
				if dt.v <= now:
					dt.v = now + p
			
			observer.on_next(count.v)
			count.v += 1
			mad.disposable = scheduler.schedule_absolute(dt.v, action_.bind(action_))
		action = action.bind(action)
		
		mad.disposable = _scheduler.schedule_absolute(dt.v, action)
		return mad
	
	return Observable.new(subscribe)

static func observable_timer_timespan(duetime : float, scheduler : SchedulerBase = null) -> Observable:
	var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var _scheduler : SchedulerBase = null
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = SceneTreeTimeoutScheduler.singleton()
		var d : float = duetime
		
		var action = func(_scheduler : SchedulerBase, _state):
			observer.on_next(0)
			observer.on_completed()
		
		if d <= 0.0:
			return _scheduler.schedule(action)
		return _scheduler.schedule_relative(d, action)
	
	return Observable.new(subscribe)

static func observable_timer_timespan_and_period(duetime : float, period : float, scheduler : SchedulerBase = null) -> Observable:
	if duetime == period:
		
		var subscribe = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
			var _scheduler : SchedulerBase = null
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
			var action = func(count = null):
				if count != null:
					observer.on_next(count)
					return count + 1
				return null
			
			if not _scheduler is PeriodicScheduler:
				BadArgumentError.new(
					"Scheduler must be PeriodicScheduler").throw()
				return Disposable.new()
			var periodic_scheduler : PeriodicScheduler = _scheduler
			return periodic_scheduler.schedule_periodic(period, action, 0)
		
		return Observable.new(subscribe)
	return observable_timer_duetime_and_period(duetime, false, period, scheduler)

static func timer_(duetime : float, time_absolute : bool, period = null, scheduler : SchedulerBase = null) -> Observable:
	if time_absolute:
		if period == null:
			return observable_timer_date(duetime, scheduler)
		else:
			var fperiod : float = period
			return observable_timer_duetime_and_period(duetime, true, fperiod, scheduler)
	
	if period == null:
		return observable_timer_timespan(duetime, scheduler)
	
	var fperiod : float = period
	return observable_timer_timespan_and_period(duetime, fperiod, scheduler)
