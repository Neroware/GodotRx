static func take_last_with_time_(
	duration : float,
	scheduler : SchedulerBase = null
) -> Callable:
	var take_last_with_time = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = TimeoutScheduler.singleton()
			
			var q : Array[Dictionary] = []
			
			var on_next = func(x):
				var now = _scheduler.now()
				q.append({"interval": now, "value": x})
				while not q.is_empty() and now - q[0]["interval"] >= duration:
					q.pop_front()
			
			var on_completed = func():
				var now = _scheduler.now()
				while not q.is_empty():
					var _next = q.pop_front()
					if now - _next["interval"] <= duration:
						observer.on_next(_next["value"])
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler_
			)
		
		return Observable.new(subscribe)
	
	return take_last_with_time
