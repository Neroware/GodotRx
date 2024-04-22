static func single_or_default_async_(
	has_default : bool = false, default_value = null
) -> Callable:
	var single_or_default_async = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var value = RefValue.Set(default_value)
			var seen_value = RefValue.Set(false)
			
			var on_next = func(x):
				if seen_value.v:
					observer.on_error(RxBaseError.new("Sequence contains more than one element"))
				else:
					value.v = x
					seen_value.v = true
			
			var on_completed = func():
				if not seen_value.v and not has_default:
					observer.on_error(SequenceContainsNoElementsError.new())
				else:
					observer.on_next(value.v)
					observer.on_completed()
			
			return source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return single_or_default_async

static func single_or_default_(
	predicate = null,
	default_value = null
) -> Callable:
#	"""Returns the only element of an observable sequence that matches
#	the predicate, or a default value if no such element exists this
#	method reports an error if there is more than one element in the
#	observable sequence.
#
#	Examples:
#		>>> var res = GDRx.op.single_or_default()
#		>>> var res = GDRx.op.single_or_default(func(x): return x == 42)
#		>>> var res = GDRx.op.single_or_default(func(x): return x == 42, 0)
#		>>> var res = GDRx.op.single_or_default(null, 0)
#
#	Args:
#		predicate -- [Optional] A predicate function to evaluate for
#			elements in the source sequence.
#		default_value -- [Optional] The default value if the index is
#			outside the bounds of the source sequence.
#
#	Returns:
#		An observable Sequence containing the single element in the
#	observable sequence that satisfies the condition in the predicate,
#	or a default value if no such element exists.
#	"""
	if predicate != null:
		var _predicate : Callable = predicate
		return GDRx.pipe.compose2(
			GDRx.op.filter(_predicate),
			GDRx.op.single_or_default(null, default_value)
		)
	else:
		return single_or_default_async_(true, default_value)
