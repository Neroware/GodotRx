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
				GDRx.filter_indexed(func(x, i): return i % int(_step == 0))
			)
		elif _step < 0:
			push_error("Negative steps not supported but.")
		
		return source.pipe(GDRx.util.Iter(pipeline))
	
	return slice
