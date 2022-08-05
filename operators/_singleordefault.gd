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
					observer.on_error(GDRx.op.Error.new("Sequence contains more than one element"))
				else:
					value.v = x
					seen_value.v = true
			
			var on_completed = func():
				if not seen_value.v and not has_default:
					observer.on_error(GDRx.err.SequenceContainsNoElementsException.new())
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
	if predicate != null:
		var _predicate : Callable = predicate
		return GDRx.pipe.compose2(
			GDRx.op.filter(_predicate),
			GDRx.op.single_or_default(null, default_value)
		)
	else:
		return single_or_default_async_(true, default_value)
