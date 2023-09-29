static func zip_(args) -> Callable:
	var _zip = func(source : Observable) -> Observable:
#		"""Merges the specified observable sequences into one observable
#		sequence by creating a tuple whenever all of the
#		observable sequences have produced an element at a corresponding
#		index.
#
#		Example:
#			>>> var res = zip.call(source)
#
#		Args:
#			source: Source observable to zip.
#
#		Returns:
#			An observable sequence containing the result of combining
#			elements of the sources as a tuple.
#		"""
		var sources : Array[Observable] = GDRx.util.unpack_arg(args)
		sources.push_front(source)
		return GDRx.obs.zip(sources)
	return _zip

static func zip_with_iterable_(seq : IterableBase) -> Callable:
	var zip_with_iterable = func(source : Observable) -> Observable:
#		"""Merges the specified observable sequence and list into one
#		observable sequence by creating a tuple whenever all of
#		the observable sequences have produced an element at a
#		corresponding index.
#
#		Example
#			>>> var res = zip_with_iterable.call(source)
#
#		Args:
#			source: Source observable to zip.
#
#		Returns:
#			An observable sequence containing the result of combining
#			elements of the sources as a tuple.
#		"""
		var first = source
		var second : Iterator = seq.iter()
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		):
			# var index = RefValue.Set(0) ? weird var def from RxPY
			
			var on_next = func(left):
				var right = second.next()
				if right is ItEnd:
					observer.on_completed()
				else:
					var result = Tuple.new([left, right])
					observer.on_next(result)
			
			return first.subscribe(
				on_next, observer.on_error, observer.on_completed, 
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return zip_with_iterable
