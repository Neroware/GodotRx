static func merge_(_sources, max_concorrent : int = -1) -> Callable:
	var merge = func(source : Observable) -> Observable:
#		"""Merges an observable sequence of observable sequences into
#		an observable sequence, limiting the number of concurrent
#		subscriptions to inner sequences. Or merges two observable
#		sequences into a single observable sequence.
#
#		Examples:
#			>>> var res = merge.call(sources)
#
#		Args:
#			source: Source observable.
#
#		Returns:
#			The observable sequence that merges the elements of the
#			inner sequences.
#		"""
		var sources : Array[Observable] = GDRx.util.unpack_arg(_sources)
		
		if max_concorrent < 0:
			var sources_ : Array[Observable] = sources.duplicate()
			sources_.push_front(source)
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
					var __ = LockGuard.new(source.lock)
					group.remove(subscription)
					if queue.size() > 0:
						var s = queue.pop_front()
						subscribe_rec__.bind(subscribe_rec__).call(s)
					else:
						active_count[0] -= 1
						if is_stopped[0] and active_count[0] == 0:
							observer.on_completed()
				
				var on_next = func(i):
					var __ = LockGuard.new(source.lock)
					observer.on_next(i)
				
				var on_error = func(e):
					var __ = LockGuard.new(source.lock)
					observer.on_error(e)
				
				subscription.disposable = xs.subscribe(
					on_next, on_error, on_completed,
					scheduler
				)
			
			var on_next = func(inner_source : Observable):
				if GDRx.assert_(max_concorrent != 0): return
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
#		"""Partially applied merge_all operator.
#
#		Merges an observable sequence of observable sequences into an
#		observable sequence.
#
#		Args:
#			source: Source observable to merge.
#
#		Returns:
#			The observable sequence that merges the elements of the inner
#			sequences.
#		"""
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
					var __ = LockGuard.new(source.lock)
					group.remove(inner_subscription)
					if is_stopped[0] and group.length == 1:
						observer.on_completed()
				
				var on_next = func(i):
					var __ = LockGuard.new(source.lock)
					observer.on_next(i)
				
				var on_error = func(e):
					var __ = LockGuard.new(source.lock)
					observer.on_error(e)
				
				var subscription = inner_source.subscribe(
					on_next, on_error, on_completed,
					scheduler
				)
				inner_subscription.set_disposable(subscription)
			
			var on_completed = func():
				is_stopped[0] = true
				if group.length == 1:
					observer.on_completed()
			
			m.disposable = source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
			return group
		
		return Observable.new(subscribe)
	
	return merge_all
