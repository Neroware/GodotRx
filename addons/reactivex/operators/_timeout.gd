static func timeout_(
	duetime : float,
	absolute : bool = false,
	other : Observable = null,
	scheduler : SchedulerBase = null
) -> Callable:
	
	var _other = other if other != null else GDRx.obs.throw(RxBaseError.new("Timeout"))
	var obs = _other
	
	var timeout = func(source : Observable) -> Observable:
#		"""Returns the source observable sequence or the other observable
#		sequence if duetime elapses.
#
#		Examples:
#			>>> var res = timeout.call(source)
#
#		Args:
#			source: Source observable to timeout
#
#		Returns:
#			An obserable sequence switching to the other sequence in
#			case of a timeout.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
			var switched = [false]
			var _id = [0]
			
			var original = SingleAssignmentDisposable.new()
			var subscription = SerialDisposable.new()
			var timer = SerialDisposable.new()
			subscription.disposable = original
			
			var create_timer = func():
				var my_id = _id[0]
				
				var action = func(scheduler : SchedulerBase, _state = null):
					switched[0] = _id[0] == my_id
					var timer_wins = switched[0]
					if timer_wins:
						subscription.disposable = obs.subscribe(
							observer, GDRx.basic.noop, GDRx.basic.noop, scheduler
						)
				
				if absolute:
					timer.disposable = _scheduler.schedule_absolute(duetime, action)
				else:
					timer.disposable = _scheduler.schedule_relative(duetime, action)
			
			create_timer.call()
			
			var on_next = func(value):
				var send_wins = not switched[0]
				if send_wins:
					_id[0] += 1
					observer.on_next(value)
					create_timer.call()
			
			var on_error = func(error):
				var on_error_wins = not switched[0]
				if on_error_wins:
					_id[0] += 1
					observer.on_error(error)
			
			var on_completed = func():
				var on_completed_wins = not switched[0]
				if on_completed_wins:
					_id[0] += 1
					observer.on_completed()
			
			original.disposable = source.subscribe(
				on_next, on_error, on_completed,
				scheduler_
			)
			return CompositeDisposable.new([subscription, timer])
		
		return Observable.new(subscribe)
	
	return timeout
