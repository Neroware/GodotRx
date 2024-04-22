static func expand_(
	mapper : Callable
) -> Callable:
	var expand = func(source : Observable) -> Observable:
#		"""Expands an observable sequence by recursively invoking
#		mapper.
#
#		Args:
#			source: Source obserable to expand.
#
#		Returns:
#			An observable sequence containing all the elements produced
#			by the recursive expansion.
#		"""
		var subscribe = func(
			observer : ObserverBase, scheduler : SchedulerBase = null
		) -> DisposableBase:
			var scheduler_ = scheduler if scheduler == null else ImmediateScheduler.singleton()
			
			var queue : Array[Observable] = []
			var m = SerialDisposable.new()
			var d = CompositeDisposable.new([m])
			var active_count = RefValue.Set(0)
			var is_aquired = RefValue.Set(false)
			
			var ensure_active = func(__ensure_active_rec : Callable):
				var is_owner = false
				if not queue.is_empty():
					is_owner = not is_aquired.v
					is_aquired.v = true
				
				var action = func(scheduler : SchedulerBase, _state = null, __action_rec : Callable = func(__, ___, ____): return):
					var work : Observable
					if not queue.is_empty():
						work = queue.pop_front()
					else:
						is_aquired.v = false
						return
					
					var sad = SingleAssignmentDisposable.new()
					d.add(sad)
					
					var on_next = func(value):
						observer.on_next(value)
						var result = RefValue.Null()
						if GDRx.try(func():
							result.v = mapper.call(value)
						) \
						.catch("Error", func(err):
							observer.on_error(err)
						) \
						.end_try_catch(): return
						
						queue.append(result.v)
						active_count.v += 1
						__ensure_active_rec.bind(__ensure_active_rec).call()
					
					var on_complete = func():
						d.remove(sad)
						active_count.v -= 1
						if active_count.v == 0:
							observer.on_completed()
					
					sad.disposable = work.subscribe(
						on_next, observer.on_error, on_complete,
						scheduler
					)
					m.disposable = scheduler.schedule(__action_rec.bind(__action_rec))
				
				if is_owner:
					m.disposable = scheduler_.schedule(action.bind(action))
			
			queue.append(source)
			active_count.v += 1
			ensure_active.bind(ensure_active).call()
			return d
		
		return Observable.new(subscribe)
	
	return expand
