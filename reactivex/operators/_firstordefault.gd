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
					observer.on_error(GDRx.err.SequenceContainsNoElementsException.new())
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
	if predicate != null:
		var predicate_ : Callable = predicate
		return GDRx.pipe.compose2(
			GDRx.op.filter(predicate_),
			GDRx.op.first_or_default(null, default_value)
		)
	return first_or_default_async_(true, default_value)
