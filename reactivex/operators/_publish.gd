static func publish_(mapper = null) -> Callable:
	if mapper != null:
		var factory = func(scheduler : SchedulerBase = null) -> Subject:
			return Subject.new()
		
		return GDRx.op.multicast(null, factory, mapper)
	
	var subject : Subject = Subject.new()
	return GDRx.op.multicast(subject)

static func share_() -> Callable:
	return GDRx.pipe.compose2(
		GDRx.op.publish(),
		GDRx.op.ref_count()
	)
