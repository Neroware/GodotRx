static func debounce_(
	duetime : float,
	scheduler : SchedulerBase = null
) -> Callable:
	var debounce = func(source : Observable) -> Observable:
#		"""Ignores values from an observable sequence which are followed by
#		another value before duetime.
#
#		Example:
#			>>> var res = debounce.call(source)
#
#		Args:
#			source: Source observable to debounce.
#
#		Returns:
#			An operator function that takes the source observable and
#			returns the debounced observable sequence.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
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
				cancelable.disposable = d
				
				var action = func(_scheduler : SchedulerBase, _state = null):
					if has_value[0] and _id[0] == current_id:
						observer.on_next(value[0])
					has_value[0] = false
				
				d.disposable = _scheduler.schedule_relative(duetime, action)
			
			var on_error = func(error):
				cancelable.dispose()
				observer.on_error(error)
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
#		"""Partially applied throttle_with_mapper operator.
#
#		Ignores values from an observable sequence which are followed by
#		another value within a computed throttle duration.
#
#		Example:
#			>>> var obs = throttle_with_mapper.call(source)
#
#		Args:
#			source: The observable source to throttle.
#
#		Returns:
#			The throttled observable sequence.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var cancelable = SerialDisposable.new()
			var has_value : RefValue = RefValue.Set(false)
			var value : RefValue = RefValue.Null()
			var _id = [0]
			
			var on_next = func(x):
				var throttle = RefValue.Null()
				if GDRx.try(func():
					throttle.v = throttle_duration_mapper.call(x)
				) \
				.catch("Error", func(e):
					observer.on_error(e)
				) \
				.end_try_catch(): return
				
				has_value.v = true
				value.v = x
				_id[0] += 1
				var current_id = _id[0]
				var d = SingleAssignmentDisposable.new()
				cancelable.disposable = d
				
				var on_next = func(__):
					if has_value.v and _id[0] == current_id:
						observer.on_next(value.v)
					has_value.v = false
					d.dispose()
				
				var on_completed = func():
					if has_value.v and _id[0] == current_id:
						observer.on_next(value.v)
					has_value.v = false
					d.dispose()
				
				d.disposable = throttle.v.subscribe(
					on_next, observer.on_error, on_completed,
					scheduler
				)
			
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
