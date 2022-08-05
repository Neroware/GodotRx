static func merge_(
	sources : Array[Observable],
	max_concorrent : int = -1
) -> Callable:
	var merge = func(source : Observable) -> Observable:
		
		if max_concorrent < 0:
			var sources_ : Array[Observable] = [source] + sources
			return GDRx.obs.merge(sources_)
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		):
			var active_count = [0]
			var group = CompositeDisposable.new()
			var is_stopped = [false]
			var queue : Array[Observable] = []
			
			var subscribe = func(xs : Observable, subscribe_rec__ : Callable):
				var subscription = SingleAssignmentDisposable.new()
				group.add(subscription)
				
				var on_completed = func():
					source._lock.lock()
					group.remove(subscription)
					if queue.size() > 0:
						var s = queue.pop_front()
						subscribe_rec__.bind(subscribe_rec__).call(s)
					else:
						active_count[0] -= 1
						if is_stopped[0] and active_count[0] == 0:
							observer.on_completed()
					source._lock.unlock()
				
				var on_next = GDRx.concur.synchronized(source._lock, 1).call(observer.on_next)
				var on_error = GDRx.concur.synchronized(source._lock, 0).call(observer.on_error)
				subscription.set_disposable(xs.subscribe(
					on_next, on_error, on_completed,
					scheduler
				))
			
			var on_next = func(inner_source : Observable):
				assert(max_concorrent > 0)
				if active_count[0] < max_concorrent:
					active_count[0] += 1
					subscribe.call(inner_source, subscribe)
				else:
					queue.append(inner_source)
			
			var on_completed = func():
				is_stopped[0] = true
				if active_count[0] == 0:
					observer.on_completed()
			
			group.add(
				source.subscribe(
					on_next, observer.on_error, on_completed,
					scheduler
				)
			)
			return group
		
		return Observable.new(subscribe)
	
	return merge


static func merge_all_() -> Callable:
	var merge_all = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		):
			var group = CompositeDisposable.new()
			var is_stopped = [false]
			var m = SingleAssignmentDisposable.new()
			group.add(m)
			
			var on_next = func(inner_source : Observable):
				var inner_subscription = SingleAssignmentDisposable.new()
				group.add(inner_subscription)
				
				var on_completed = func():
					source._lock.lock()
					group.remove(inner_subscription)
					if is_stopped[0] and group.length() == 1:
						observer.on_completed()
					source._lock.unlock()
				
				var on_next : Callable = GDRx.concur.synchronized(source._lock, 1).call(observer.on_next)
				var on_error : Callable = GDRx.concur.synchronized(source._lock, 0).call(observer.on_error)
				var subscription = inner_source.subscribe(
					on_next, on_error, on_completed,
					scheduler
				)
				inner_subscription.set_disposable(subscription)
			
			var on_completed = func():
				is_stopped[0] = true
				if group.length() == 1:
					observer.on_completed()
			
			m.set_disposable(source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			))
			return group
		
		return Observable.new(subscribe)
	
	return merge_all
