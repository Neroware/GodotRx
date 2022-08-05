static func repeat_value_(value, repeat_count = null) -> Observable:
	
	if repeat_count == -1:
		repeat_count = null
	
	var xs : Observable = GDRx.obs.return_value(value)
	return xs.pipe1(GDRx.op.repeat(repeat_count))
