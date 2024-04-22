static func map_(
	mapper : Callable = GDRx.basic.identity
) -> Callable:
	var _mapper = mapper
	
	var map = func(source : Observable) -> Observable:
#		"""Partially applied map operator.
#
#		Project each element of an observable sequence into a new form
#		by incorporating the element's index.
#
#		Example:
#			>>> map.call(source)
#
#		Args:
#			source: The observable source to transform.
#
#		Returns:
#			Returns an observable sequence whose elements are the
#			result of invoking the transform function on each element
#			of the source.
#		"""
		var subscribe = func(
			obv : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var on_next = func(value):
				var result = RefValue.Null()
				if not GDRx.try(func():
					result.v = _mapper.call(value)
				) \
				.catch("Error", func(err):
					obv.on_error(err)
				) \
				.end_try_catch():
					obv.on_next(result.v)
			
			return source.subscribe(
				on_next, obv.on_error, obv.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return map

static func map_indexed_(
	mapper_indexed : Callable = GDRx.basic.identity
) -> Callable:
	var _mapper_indexed = mapper_indexed
	
	return GDRx.pipe.compose2(
		GDRx.op.zip_with_iterable(InfiniteIterable.new()),
		GDRx.op.map(func(i : Tuple): return _mapper_indexed.call(i.at(0), i.at(1)))
	)
