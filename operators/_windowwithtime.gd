static func window_with_time_(
	timespan : float,
	timeshift = null,
	scheduler : SchedulerBase = null
) -> Callable:
	if timeshift == null:
		timeshift = timespan
	
	var window_with_time = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
			var timer_d = SerialDisposable.new()
			var next_shift = [timeshift]
			var next_span = [timespan]
			var total_time = [Scheduler.DELTA_ZERO]
			var queue : Array[Subject] = []
			
			var group_disposable = CompositeDisposable.new(timer_d)
			var ref_count_disposable = RefCountDisposable.new(group_disposable)
			
			var create_timer = func(__create_timer_rec : Callable):
				var m = SingleAssignmentDisposable.new()
				timer_d.disposable = m
				var is_span = false
				var is_shift = false
				
				if next_span[0] == next_shift[0]:
					is_span = true
					is_shift = true
				elif next_span[0] < next_shift[0]:
					is_span = true
				else:
					is_shift = true
				
				var new_total_time = next_span[0] if is_span else next_shift[0]
				var ts = new_total_time - total_time[0]
				total_time[0] = new_total_time
				if is_span:
					next_span[0] += timeshift
				if is_shift:
					next_shift[0] += timeshift
				
				var action = func(_scheduler : SchedulerBase, _state = null):
					var __ = LockGuard.new(source.lock)
					var s : Subject = null
					
					if is_shift:
						s = Subject.new()
						queue.append(s)
						observer.on_next(GDRx.util.add_ref(s.as_observable(), ref_count_disposable))
					
					if is_span:
						s = queue.pop_front()
						s.on_completed()
					
					__create_timer_rec.bind(__create_timer_rec).call()
				
				m.disposable = _scheduler.schedule_relative(ts, action)
			
			queue.append(Subject.new())
			observer.on_next(GDRx.util.add_ref(queue[0].as_observable(), ref_count_disposable))
			create_timer.bind(create_timer).call()
			
			var on_next = func(x):
				var __ = LockGuard.new(source.lock)
				for s in queue:
					s.as_observer().on_next(x)
			
			var on_error = func(e):
				var __ = LockGuard.new(source.lock)
				for s in queue:
					s.as_observer().on_error(e)
				observer.on_error(e)
			
			var on_completed = func():
				var __ = LockGuard.new(source.lock)
				for s in queue:
					s.as_observer().on_completed()
				observer.on_completed()
			
			group_disposable.add(source.subscribe(
				on_next, on_error, on_completed,
				scheduler_
			))
			return ref_count_disposable
		
		return Observable.new(subscribe)
	
	return window_with_time
