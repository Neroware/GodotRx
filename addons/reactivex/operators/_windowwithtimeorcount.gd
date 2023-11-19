static func window_with_time_or_count_(
	timespan : float,
	count : int,
	scheduler : SchedulerBase = null
) -> Callable:
	
	var window_with_time_or_count = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
			var n : RefValue = RefValue.Set(0)
			var s : RefValue = RefValue.Set(Subject.new())
			var timer_d = SerialDisposable.new()
			var window_id : RefValue = RefValue.Set(0)
			var group_disposable = CompositeDisposable.new([timer_d])
			var ref_count_disposable = RefCountDisposable.new(group_disposable)
			
			var create_timer = func(_id : int, __create_timer_rec : Callable):
				var m = SingleAssignmentDisposable.new()
				timer_d.v.disposable = m
				
				var action = func(_scheduler : SchedulerBase, _state = null):
					if _id != window_id.v:
						return
					
					n.v = 0
					window_id.v += 1
					var new_id = window_id.v
					s.v.on_completed()
					s.v = Subject.new()
					observer.on_next(GDRx.util.add_ref(s.v.as_observable(), ref_count_disposable))
					__create_timer_rec.bind(__create_timer_rec).call(new_id)
				
				m.disposable = _scheduler.schedule_relative(timespan, action)
			
			observer.on_next(GDRx.util.add_ref(s.v.as_observable(), ref_count_disposable))
			create_timer.bind(create_timer).call(0)
			
			var on_next = func(x):
				var new_window = false
				var new_id = 0
				
				s.v.on_next(x)
				n.v += 1
				if n.v == count:
					new_window = true
					n.v = 0
					window_id.v += 1
					new_id = window_id.v
					s.v.on_completed()
					s.v = Subject.new()
					observer.on_next(GDRx.util.add_ref(s.v.as_observable(), ref_count_disposable))
				
				if new_window:
					create_timer.bind(create_timer).call(new_id)
			
			var on_error = func(e):
				s.v.on_error(e)
				observer.on_error(e)
			
			var on_completed = func():
				s.v.on_completed()
				observer.on_completed()
			
			group_disposable.add(source.subscribe(
				on_next, on_error, on_completed,
				scheduler_)
			)
			return ref_count_disposable
		
		return Observable.new(subscribe)
	
	return window_with_time_or_count
