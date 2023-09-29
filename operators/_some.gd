static func some_(
	predicate = null
) -> Callable:
	var some = func(source : Observable) -> Observable:
#		"""Partially applied operator.
#
#		Determines whether some element of an observable sequence satisfies a
#		condition if present, else if some items are in the sequence.
#
#		Example:
#			>>> var obs = some.call(source)
#
#		Args:
#			predicate -- A function to test each element for a condition.
#
#		Returns:
#			An observable sequence containing a single element
#			determining whether some elements in the source sequence
#			pass the test in the specified predicate if given, else if
#			some items are in the sequence.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_next = func(__):
				observer.on_next(true)
				observer.on_completed()
			
			var on_error = func():
				observer.on_next(false)
				observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_error,
				scheduler
			)
		
		if predicate != null:
			var predicate_ : Callable = predicate
			return source.pipe2(
				GDRx.op.filter(predicate_),
				some_()
			)
		
		return Observable.new(subscribe)
	
	return some
