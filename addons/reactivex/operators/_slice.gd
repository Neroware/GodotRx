static func slice_(
	start : int = 0, 
	stop : int = GDRx.util.MAX_SIZE,
	step : int = 1
) -> Callable:
	var _start = start
	var _stop = stop
	var _step = step
	
	var pipeline : Array[Callable] = []
	
	var slice = func(source : Observable) -> Observable:
#		"""The partially applied slice operator.
#
#		Slices the given observable. It is basically a wrapper around the operators
#		GDRx.op.skip,
#		GDRx.op.skip_last,
#		GDRx.op.take,
#		GDRx.op.take_last and
#		GDRx.op.filter.
#
#		The following diagram helps you remember how slices works with streams.
#
#		Positive numbers are relative to the start of the events, while negative
#		numbers are relative to the end (close) of the stream.
#
#		.. code::
#
#			r---e---a---c---t---i---v---e---!
#			0   1   2   3   4   5   6   7   8
#		   -8  -7  -6  -5  -4  -3  -2  -1   0
#
#		Examples:
#			>>> var result = source.pipe1(GDRx.op.slice(1, 10))
#			>>> var result = source.pipe1(GDRx.op.slice(1, -2))
#			>>> var result = source.pipe1(GDRx.op.slice(1, -1, 2))
#
#		Args:
#			source: Observable to slice
#
#		Returns:
#			A sliced observable sequence.
#		"""
		if _stop >= 0:
			pipeline.append(GDRx.op.take(_stop))
		
		if _start > 0:
			pipeline.append(GDRx.op.skip(_start))
		elif _start < 0:
			pipeline.append(GDRx.op.take_last(-_start))
		
		if _stop < 0:
			pipeline.append(GDRx.op.take_last(-_stop))
		
		if _step > 1:
			pipeline.append(
				GDRx.filter_indexed(func(_x, i): return i % int(_step == 0))
			)
		elif _step < 0:
			ArgumentOutOfRangeError.raise()
		
		return source.pipe(GDRx.util.Iter(pipeline))
	
	return slice
