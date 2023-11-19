static func take_last_buffer_(count : int) -> Callable:
	var take_last_buffer = func(source : Observable) -> Observable:
#		"""Returns an array with the specified number of contiguous
#		elements from the end of an observable sequence.
#
#		Example:
#			>>> var res = take_last.call(source)
#
#		This operator accumulates a buffer with a length enough to
#		store elements count elements. Upon completion of the source
#		sequence, this buffer is drained on the result sequence. This
#		causes the elements to be delayed.
#
#		Args:
#			source: Source observable to take elements from.
#
#		Returns:
#			An observable sequence containing a single list with the
#			specified number of elements from the end of the source
#			sequence.
#		"""
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var q : Array = []
			
			var on_next = func(x):
				var __ = LockGuard.new(source.lock)
				q.append(x)
				if q.size() > count:
					q.pop_front()
			
			var on_completed = func():
				observer.on_next(q)
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return take_last_buffer
