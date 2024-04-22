static func last_or_default_async(
	source : Observable,
	has_default : bool = false,
	default_value = null
) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var value = [default_value]
		var seen_value = [false]
		
		var on_next = func(x):
			value[0] = x
			seen_value[0] = true
		
		var on_completed = func():
			if not seen_value[0] and not has_default:
				observer.on_error(SequenceContainsNoElementsError.new())
			else:
				observer.on_next(value[0])
				observer.on_completed()
		
		return source.subscribe(
			on_next, observer.on_error, on_completed,
			scheduler
		)
	
	return Observable.new(subscribe)

static func last_or_default_(
	default_value = null, predicate = null
) -> Callable:
	var last_or_default = func(source : Observable) -> Observable:
#		"""Return last or default element.
#
#		Examples:
#			>>> var res = last_or_default.call(source)
#
#		Args:
#			source: Observable sequence to get the last item from.
#
#		Returns:
#			Observable sequence containing the last element in the
#			observable sequence.
#		"""
		if predicate != null:
			var predicate_ : Callable = predicate
			return source.pipe2(
				GDRx.op.filter(predicate_),
				GDRx.op.last_or_default(default_value)
			)
		
		return last_or_default_async(source, true, default_value)
	
	return last_or_default
