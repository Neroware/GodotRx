static func take_last_with_time_(
	duration : float,
	scheduler : SchedulerBase = null
) -> Callable:
	var take_last_with_time = func(source : Observable) -> Observable:
#		"""Returns elements within the specified duration from the end
#		of the observable source sequence.
#
#		Example:
#			>>> var res = take_last_with_time.call(source)
#
#		This operator accumulates a queue with a length enough to store
#		elements received during the initial duration window. As more
#		elements are received, elements older than the specified
#		duration are taken from the queue and produced on the result
#		sequence. This causes elements to be delayed with duration.
#
#		Args:
#			duration: Duration for taking elements from the end of the
#			sequence.
#
#		Returns:
#			An observable sequence with the elements taken during the
#			specified duration from the end of the source sequence.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
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
