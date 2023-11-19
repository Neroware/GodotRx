static func switch_latest_() -> Callable:
	var switch_latest = func(source : Observable) -> Observable:
#		"""Partially applied switch_latest operator.
#
#		Transforms an observable sequence of observable sequences into
#		an observable sequence producing values only from the most
#		recent observable sequence.
#
#		Returns:
#			An observable sequence that at any point in time produces
#			the elements of the most recent inner observable sequence
#			that has been received.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var inner_subscription = SerialDisposable.new()
			var has_latest = [false]
			var is_stopped = [false]
			var latest = [0]
			
			var on_next = func(inner_source : Observable):
				var d = SingleAssignmentDisposable.new()
				var _id
				if true:
					var __ = LockGuard.new(source.lock)
					latest[0] += 1
					_id = latest[0]
				has_latest[0] = true
				inner_subscription.disposable = d
				
				var obs = inner_source
				
				var on_next = func(x):
					if latest[0] == _id:
						observer.on_next(x)
				
				var on_error = func(e):
					if latest[0] == _id:
						observer.on_error(e)
				
				var on_completed = func():
					if latest[0] == _id:
						has_latest[0] = false
						if is_stopped[0]:
							observer.on_completed()
				
				d.disposable = obs.subscribe(
					on_next, on_error, on_completed,
					scheduler
				)
			
			var on_completed = func():
				is_stopped[0] = true
				if not has_latest[0]:
					observer.on_completed()
			
			var subscription = source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
			return CompositeDisposable.new([
				subscription, inner_subscription
			])
		
		return Observable.new(subscribe)
	
	return switch_latest
