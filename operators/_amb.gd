static func amb_(right_source : Observable) -> Callable:
	var obs : Observable = right_source
	
	var amb = func(left_source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var choice = [null]
			var left_choice = "L"
			var right_choice = "R"
			var left_subscription : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
			var right_subscription : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
			
			var choice_left = func():
				if choice[0] == null:
					choice[0] = left_choice
					right_subscription.dispose()
			
			var choice_right = func():
				if choice[0] == null:
					choice[0] = right_choice
					left_subscription.dispose()
			
			var on_next_left = func(value):
				if true:
					var __ = LockGuard.new(left_source.lock)
					choice_left.call()
				if choice[0] == left_choice:
					observer.on_next(value)
			
			var on_error_left = func(err):
				if true:
					var __ = LockGuard.new(left_source.lock)
					choice_left.call()
				if choice[0] == left_choice:
					observer.on_error(err)
			
			var on_completed_left = func():
				if true:
					var __ = LockGuard.new(left_source.lock)
					choice_left.call()
				if choice[0] == left_choice:
					observer.on_completed()
			
			var left_d = left_source.subscribe(
				on_next_left, on_error_left, on_completed_left,
				scheduler
			)
			left_subscription.disposable = left_d
			
			var on_next_right = func(value):
				if true:
					var __ = LockGuard.new(left_source.lock)
					choice_right.call()
				if choice[0] == right_choice:
					observer.on_next(value)
			
			var on_error_right = func(err):
				if true:
					var __ = LockGuard.new(left_source.lock)
					choice_right.call()
				if choice[0] == right_choice:
					observer.on_error(err)
			
			var on_completed_right = func():
				if true:
					var __ = LockGuard.new(left_source.lock)
					choice_right.call()
				if choice[0] == right_choice:
					observer.on_completed()
			
			var right_d = obs.subscribe(
				on_next_right, on_error_right, on_completed_right,
				scheduler
			)
			right_subscription.disposable = right_d
			return CompositeDisposable.new([left_subscription, right_subscription])
		
		return Observable.new(subscribe)
	
	return amb
