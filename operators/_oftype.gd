static func oftype_(type, push_err : bool = true) -> Callable:
	var oftype = func(source : Observable) -> Observable:
#		"""Partially applied oftype operator.
#
#		Fixes the type of an element to a specific class. Elements of wrong 
#		type cause an Exception.
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
				var type_mismatch : bool = false
				
				if type is int:
					type_mismatch = typeof(value) != type
				elif type is GDScript:
					type_mismatch = not (value is type)
				else:
					var msg = "Type fixation operator only accepts type codes " \
						+ " as integer value or GDScript instances as parameter!"
					observer.on_error(GDRx.exc.BadArgumentException.new(msg))
					return
				
				if type_mismatch:
					var exc = GDRx.exc.TypeMismatchException.new(value)
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
