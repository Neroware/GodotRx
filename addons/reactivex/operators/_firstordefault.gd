static func first_or_default_async_(
	has_default : bool = false, default_value = null
) -> Callable:
	var first_or_default_async = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			
			var on_next = func(x):
				observer.on_next(x)
				observer.on_completed()
			
			var on_completed = func():
				if not has_default:
					observer.on_error(SequenceContainsNoElementsError.new())
				else:
					observer.on_next(default_value)
					observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return first_or_default_async

static func first_or_default_(
	predicate = null,
	default_value = null
) -> Callable:
#	"""Returns the first element of an observable sequence that
#	satisfies the condition in the predicate, or a default value if no
#	such element exists.
#
#	Examples:
#		>>> var res = source.pipe1(GDRx.op.first_or_default())
#		>>> var res = source.pipe1(GDRx.op.first_or_default(func(x): return x > 3))
#		>>> var res = source.pipe1(GDRx.op.first_or_default(func(x): return x > 3, 0))
#		>>> var res = source.pipe1(GDRx.op.first_or_default(null, 0))
#
#	Args:
#		source -- Observable sequence.
#		predicate -- [optional] A predicate function to evaluate for
#			elements in the source sequence.
#		default_value -- [Optional] The default value if no such element
#			exists.  If not specified, defaults to None.
#
#	Returns:
#		A function that takes an observable source and reutrn an
#		observable sequence containing the first element in the
#		observable sequence that satisfies the condition in the
#		predicate, or a default value if no such element exists.
#	"""
	if predicate != null:
		var predicate_ : Callable = predicate
		return GDRx.pipe.compose2(
			GDRx.op.filter(predicate_),
			GDRx.op.first_or_default(null, default_value)
		)
	return first_or_default_async_(true, default_value)
