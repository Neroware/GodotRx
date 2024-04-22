static func oftype_(type, push_err : bool = true, type_equality : Callable = GDRx.basic.default_type_equality) -> Callable:
	var oftype = func(source : Observable) -> Observable:
#		"""Partially applied oftype operator.
#
#		Fixes the type of an element to a specific class. Elements of wrong 
#		type cause an error.
#
#		Example:
#			>>> oftype.call(source)
#
#		Args:
#			source: Source observable to oftype.
#
#		Returns:
#			An observable sequence with fixed type.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_next = func(value):
				var type_mismatch : bool = not type_equality.call(type, value)
				if type_mismatch:
					var exc = TypeMismatchError.new(value)
					observer.on_error(exc)
					if push_err:
						push_error(exc)
				else:
					observer.on_next(value)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return oftype
