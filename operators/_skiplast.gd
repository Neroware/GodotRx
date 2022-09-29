static func skip_last_(count : int) -> Callable:
	var skip_last = func(source : Observable) -> Observable:
#		"""Bypasses a specified number of elements at the end of an
#		observable sequence.
#
#		This operator accumulates a queue with a length enough to store
#		the first `count` elements. As more elements are received,
#		elements are taken from the front of the queue and produced on
#		the result sequence. This causes elements to be delayed.
#
#		Args:
#			count: Number of elements to bypass at the end of the
#			source sequence.
#
#		Returns:
#			An observable sequence containing the source sequence
#			elements except for the bypassed ones at the end.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var q : Array = []
			
			var on_next = func(value):
				var front = null
				source.lock.lock()
				q.append(value)
				if q.size() > count:
					front = q.pop_front()
				source.lock.unlock()
				
				if front != null:
					observer.on_next(front)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return skip_last
