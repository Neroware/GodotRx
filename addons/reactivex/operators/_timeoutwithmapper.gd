static func timeout_with_mapper_(
	first_timeout : Observable = null,
	timeout_duration_mapper : Callable = func(__) -> Observable: return GDRx.obs.never(),
	other : Observable = null
) -> Callable:
	
#	"""Returns the source observable sequence, switching to the other
#	observable sequence if a timeout is signaled.
#
#		var res = GDRx.obs.timeout_with_mapper(GDRx.obs.timer(500))
#		var res = GDRx.obs.timeout_with_mapper(GDRx.obs.timer(500), func(x): return GDRx.obs.timer(200))
#		var res = GDRx.obs.timeout_with_mapper(
#			GDRx.obs.timer(500),
#			func(x): return GDRx.obs.timer(200)),
#			GDRx.obs.return_value(42)
#		)
#
#	Args:
#		first_timeout -- [Optional] Observable sequence that represents the
#			timeout for the first element. If not provided, this defaults to
#			reactivex.never().
#		timeout_duration_mapper -- [Optional] Selector to retrieve an
#			observable sequence that represents the timeout between the
#			current element and the next element.
#		other -- [Optional] Sequence to return in case of a timeout. If not
#			provided, this is set to reactivex.throw().
#
#	Returns:
#		The source sequence switching to the other sequence in case
#	of a timeout.
#	"""
	
	var first_timeout_ = first_timeout if first_timeout != null else GDRx.obs.never()
	var other_ = other if other != null else GDRx.obs.throw(RxBaseError.new("Timeout"))
	
	var timeout_with_mapper = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var subscription = SerialDisposable.new()
			var timer = SerialDisposable.new()
			var original = SingleAssignmentDisposable.new()
			
			subscription.disposable = original
			
			var switched = false
			var _id = [0]
			
			var set_timer = func(timeout : Observable):
				var my_id = _id[0]
				
				var timer_wins = func():
					return _id[0] == my_id
				
				var d = SingleAssignmentDisposable.new()
				timer.disposable = d
				
				var on_next = func(__):
					if timer_wins.call():
						subscription.disposable = other_.subscribe(
							observer, GDRx.basic.noop, GDRx.basic.noop, scheduler
						)
					
					d.dispose()
				
				var on_error = func(e):
					if timer_wins.call():
						observer.on_error(e)
				
				var on_completed = func():
					if timer_wins.call():
						subscription.disposable = other_.subscribe(
							observer
						)
				
				d.disposable = timeout.subscribe(
					on_next, on_error, on_completed,
					scheduler
				)
			
			set_timer.call(first_timeout_)
			
			var observer_wins = func():
				var res = not switched
				if res:
					_id[0] += 1
				
				return res
			
			var on_next = func(x):
				if observer_wins.call():
					observer.on_next(x)
					var timeout = RefValue.Null()
					if GDRx.try(func():
						timeout.v = timeout_duration_mapper.call(x)
					) \
					.catch("Error", func(e):
						observer.on_error(e)
					) \
					.end_try_catch(): return
					
					set_timer.call(timeout.v)
			
			var on_error = func(error):
				if observer_wins.call():
					observer.on_error(error)
			
			var on_completed = func():
				if observer_wins.call():
					observer.on_completed()
			
			original.disposable = source.subscribe(
				on_next, on_error, on_completed,
				scheduler
			)
			return CompositeDisposable.new([subscription, timer])
		
		return Observable.new(subscribe)
	
	return timeout_with_mapper
