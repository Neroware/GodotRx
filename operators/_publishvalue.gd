static func publish_value_(
	initial_value,
	mapper = null
) -> Callable:
	if mapper != null:
		
		var subject_factory = func(
			_scheduler : SchedulerBase
		) -> BehaviorSubject:
			return BehaviorSubject.new(initial_value)
		
		return GDRx.op.multicast(
			null, subject_factory, mapper
		)
	
	var subject = BehaviorSubject.new(initial_value)
	return GDRx.op.multicast(subject)
