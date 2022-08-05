static func debounce_(
	duetime : float,
	scheduler : SchedulerBase = null
) -> Callable:
	var debounce = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = TimeoutScheduler.singleton()
			var cancelable = SerialDisposable.new()
			var has_value = [false]
			var value : Array = [null]
			var _id : Array[int] = [0]
			
			var on_next = func(x):
				has_value[0] = true
				value[0] = x
				_id[0] += 1
				var current_id = _id[0]
				var d = SingleAssignmentDisposable.new()
				cancelable.set_disposable(d)
				
				var action = func(scheduler : SchedulerBase, state = null):
					if has_value[0] and _id[0] == current_id:
						observer.on_next(value[0])
					has_value[0] = false
				
				d.set_disposable(_scheduler.schedule_relative(duetime, action))
			
			var on_error = func(exception):
				cancelable.dispose()
				observer.on_error(exception)
				has_value[0] = false
				_id[0] += 1
			
			var on_completed = func():
				cancelable.dispose()
				if has_value[0]:
					observer.on_next(value[0])
				
				observer.on_completed()
				has_value[0] = false
				_id[0] += 1
			
			var subscription = source.subscribe(
				on_next, on_error, on_completed,
				scheduler_
			)
			return CompositeDisposable.new([subscription, cancelable])
		
		return Observable.new(subscribe)
	
	return debounce

func throttle_with_mapper_(
	throttle_duration_mapper : Callable
) -> Callable:
	var throttle_with_mapper = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var cancelable = SerialDisposable.new()
			var has_value : RefValue = RefValue.Set(false)
			var value : RefValue = RefValue.Null()
			var _id = [0]
			
			var on_next = func(x):
				var throttle = null
				throttle = throttle_duration_mapper.call(x)
				if throttle is GDRx.err.Error:
					observer.on_error(throttle)
					return
				
				has_value.v = true
				value.v = x
				_id[0] += 1
				var current_id = _id[0]
				var d = SingleAssignmentDisposable.new()
				cancelable.set_disposable(d)
				
				var on_next = func(x):
					if has_value.v and _id[0] == current_id:
						observer.on_next(value.v)
					has_value.v = false
					d.dispose()
				
				var on_completed = func():
					if has_value.v and _id[0] == current_id:
						observer.on_next(value.v)
					has_value.v = false
					d.dispose()
				
				d.set_disposable(throttle.subscribe(
					on_next, observer.on_error, on_completed,
					scheduler
				))
			
			var on_error = func(e):
				cancelable.dispose()
				observer.on_error(e)
				has_value.v = false
				_id[0] += 1
			
			var on_completed = func():
				cancelable.dispose()
				if has_value.v:
					observer.on_next(value.v)
				
				observer.on_completed()
				has_value.v = false
				_id[0] += 1
			
			var subscription = source.subscribe(
				on_next, on_error, on_completed.
				scheduler
			)
			return CompositeDisposable.new([subscription, cancelable])
		
		return Observable.new(subscribe)
	
	return throttle_with_mapper
