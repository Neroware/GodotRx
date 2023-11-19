static func take_until_(
	other : Observable
) -> Callable:
	var obs = other
	
	var take_until = func(source : Observable) -> Observable:
#		"""Returns the values from the source observable sequence until
#		the other observable sequence produces a value.
#
#		Args:
#			source: The source observable sequence.
#
#		Returns:
#			An observable sequence containing the elements of the source
#			sequence up to the point the other sequence interrupted
#			further propagation.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_completed = func(__):
				observer.on_completed()
			
			return CompositeDisposable.new([
				source.subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, scheduler),
				obs.subscribe(on_completed, observer.on_error, func():return, scheduler)
			])
		
		return Observable.new(subscribe)
	
	return take_until
