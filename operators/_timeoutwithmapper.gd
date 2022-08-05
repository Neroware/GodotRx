static func timeout_with_mapper_(
	first_timeout : Observable = null,
	timeout_duration_mapper : Callable = func(__) -> Observable: return GDRx.obs.never(),
	other : Observable = null
) -> Callable:
	
	var first_timeout_ = first_timeout if first_timeout != null else GDRx.obs.never()
	var other_ = other if other != null else GDRx.obs.throw(GDRx.err.Error.new("Timeout"))
	
	var timeout_with_mapper = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var subscription = SerialDisposable.new()
			var timer = SerialDisposable.new()
			var original = SingleAssignmentDisposable.new()
			
			subscription.set_disposable(original)
			
			var switched = false
			var _id = [0]
			
			var set_timer = func(timeout : Observable):
				var my_id = _id[0]
				
				var timer_wins = func():
					return _id[0] == my_id
				
				var d = SingleAssignmentDisposable.new()
				timer.set_disposable(d)
				
				var on_next = func(x):
					if timer_wins.call():
						subscription.set_disposable(other_.subscribe(
							observer, func(e):return, func():return, scheduler
						))
					
					d.dispose()
				
				var on_error = func(e):
					if timer_wins.call():
						observer.on_error(e)
				
				var on_completed = func():
					if timer_wins.call():
						subscription.set_disposable(other_.subscribe(
							observer
						))
				
				d.set_disposable(timeout.subscribe(
					on_next, on_error, on_completed,
					scheduler
				))
			
			set_timer.call(first_timeout_)
			
			var observer_wins = func():
				var res = not switched
				if res:
					_id[0] += 1
				
				return res
			
			var on_next = func(x):
				if observer_wins.call():
					observer.on_next(x)
					var timeout = null
					timeout = timeout_duration_mapper.call(x)
					if timeout is GDRx.err.Error:
						observer.on_error(timeout)
						return
					set_timer.call(timeout)
			
			var on_error = func(error):
				if observer_wins.call():
					observer.on_error(error)
			
			var on_completed = func():
				if observer_wins.call():
					observer.on_completed()
			
			original.set_disposable(source.subscribe(
				on_next, on_error, on_completed,
				scheduler
			))
			return CompositeDisposable.new([subscription, timer])
		
		return Observable.new(subscribe)
	
	return timeout_with_mapper
