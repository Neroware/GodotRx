static func window_with_count_(
	count : int, skip = null
) -> Callable:
	"""Projects each element of an observable sequence into zero or more
	windows which are produced based on element count information.

	Examples:
		>>> GDRx.op.window_with_count(10)
		>>> GDRx.op.window_with_count(10, 1)

	Args:
		count: Length of each window.
		skip: [Optional] Number of elements to skip between creation of
			consecutive windows. If not specified, defaults to the
			count.

	Returns:
		An observable sequence of windows.
	"""
	if count <= 0:
		GDRx.exc.ArgumentOutOfRangeException.new().throw()
		count = 1
	
	var skip_ : int = skip if skip != null else count
	if skip_ <= 0:
		GDRx.exc.ArgumentOutOfRangeException.new().throw()
		skip_ = 1
	
	var window_with_count = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var m = SingleAssignmentDisposable.new()
			var refCountDisposable = RefCountDisposable.new(m)
			var n = [0]
			var q : Array[Subject] = []
			
			var create_window = func():
				var s : Subject = Subject.new()
				q.append(s)
				observer.on_next(GDRx.util.AddRef(s.as_observable(), refCountDisposable))
			
			create_window.call()
			
			var on_next = func(x):
				for item in q:
					item.as_observer().on_next(x)
				
				var c = n[0] - count + 1
				if c >= 0 and c % skip_ == 0:
					var s = q.pop_front()
					s.as_observer().on_completed()
				
				n[0] += 1
				if (n[0] % skip_) == 0:
					create_window.call()
			
			var on_error = func(exception):
				while not q.is_empty():
					q.pop_front().as_observer().on_error(exception)
				observer.on_error(exception)
			
			var on_completed = func():
				while not q.is_empty():
					q.pop_front().as_observer().on_completed()
				observer.on_completed()
			
			m.set_disposable(source.subscribe(
				on_next, on_error, on_completed,
				scheduler
			))
			return refCountDisposable
		
		return Observable.new(subscribe)
	
	return window_with_count
