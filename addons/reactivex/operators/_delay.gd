static func observable_delay_timespan(
	source : Observable,
	duetime : float,
	scheduler : SchedulerBase = null
) -> Observable:
	var _duetime : RefValue = RefValue.Set(duetime)
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler_ : SchedulerBase = null
	) -> DisposableBase:
		var _scheduler : SchedulerBase
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = SceneTreeTimeoutScheduler.singleton()
		
		var duetime_ = _duetime.v
		
		var cancelable = SerialDisposable.new()
		var error : RefValue = RefValue.Null()
		var active = [false]
		var running = [false]
		var queue : Array[Tuple] = []
		
		@warning_ignore("shadowed_variable") 
		var on_next = func(notification : Tuple):
			var should_run = false
			
			if true:
				var __ = LockGuard.new(source.lock)
				if notification.at(0) is OnErrorNotification:
					queue.clear()
					queue.append(notification)
					error.v = notification.at(0).err
					should_run = not running[0]
				else:
					queue.append(
						Tuple.new([
							notification.at(0),
							notification.at(1) + duetime_
						])
					)
					should_run = not active[0]
					active[0] = true
			
			if should_run:
				if error.v != null:
					observer.on_error(error.v)
				else:
					var mad = MultipleAssignmentDisposable.new()
					cancelable.disposable = mad
					
					var action = func(scheduler : SchedulerBase, _state = null, __action_rec : Callable = func(__, ___, ____): return null):
						if error.v != null:
							return
						
						var err
						var should_continue : bool
						var recurse_duetime : float
						if true:
							var __ = LockGuard.new(source.lock)
							running[0] = true
							while true:
								var result : Notification = null
								if not queue.is_empty() and queue[0].at(1) <= scheduler.now():
									result = queue.pop_front().at(0)
								
								if result != null:
									result.accept(observer)
								
								if result == null:
									break
							
							should_continue = false
							recurse_duetime = 0
							if not queue.is_empty():
								should_continue = true
								var diff = queue[0].at(1) - scheduler.now()
								recurse_duetime = max(0, diff)
							else:
								active[0] = false
							
							err = error.v
							running[0] = false
						
						if err != null:
							observer.on_error(err)
						elif should_continue:
							mad.disposable = scheduler.schedule_relative(
								recurse_duetime, __action_rec.bind(__action_rec)
							)
					
					mad.disposable = _scheduler.schedule_relative(duetime_, action.bind(action))
		
		var subscription = source.pipe2(
			GDRx.op.materialize(),
			GDRx.op.timestamp()
		).subscribe(on_next, GDRx.basic.noop, GDRx.basic.noop, _scheduler)
		
		return CompositeDisposable.new([subscription, cancelable])
	
	return Observable.new(subscribe)

static func delay_(
	duetime : float, scheduler : SchedulerBase = null
) -> Callable:
	var delay = func(source : Observable) -> Observable:
#		"""Time shifts the observable sequence.
#
#		A partially applied delay operator function.
#
#		Examples:
#			>>> var res = delay.call(source)
#
#		Args:
#			source: The observable sequence to delay.
#
#		Returns:
#			A time-shifted observable sequence.
#		"""
		return observable_delay_timespan(source, duetime, scheduler)
	
	return delay
