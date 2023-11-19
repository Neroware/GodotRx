static func buffer_(boundaries : Observable) -> Callable:
	return GDRx.pipe.compose2(
		GDRx.op.window(boundaries),
		GDRx.op.flat_map(GDRx.op.to_list()),
	)

static func buffer_when_(closing_mapper : Callable) -> Callable:
	return GDRx.pipe.compose2(
		GDRx.op.window_when(closing_mapper),
		GDRx.op.flat_map(GDRx.op.to_list()),
	)

static func buffer_toggle_(openings : Observable, closing_mapper : Callable) -> Callable:
	return GDRx.pipe.compose2(
		GDRx.op.window_toggle(openings, closing_mapper),
		GDRx.op.flat_map(GDRx.op.to_list()),
	)

static func buffer_with_count_(
	count : int, skip = null
) -> Callable:
	var _skip = RefValue.Set(skip)
#	"""Projects each element of an observable sequence into zero or more
#	buffers which are produced based on element count information.
#
#	Examples:
#		>>> var res = GDRx.op.buffer_with_count(10).call(xs)
#		>>> var res = GDRx.op.buffer_with_count(10, 1).call(xs)
#
#	Args:
#		count: Length of each buffer.
#		skip: [Optional] Number of elements to skip between
#			creation of consecutive buffers. If not provided, defaults to
#			the count.
#
#	Returns:
#		A function that takes an observable source and returns an
#		observable sequence of buffers.
#	"""
	var buffer_with_count = func(source : Observable) -> Observable:
		if _skip.v == null:
			_skip.v = count
		
		var mapper = func(value : Observable) -> Observable:
			return value.pipe1(GDRx.op.to_list())
		
		var predicate = func(value : Array) -> bool:
			return value.size() > 0
		
		return source.pipe3(
			GDRx.op.window_with_count(count, _skip.v),
			GDRx.op.flat_map(mapper),
			GDRx.op.filter(predicate)
		)
	
	return buffer_with_count
