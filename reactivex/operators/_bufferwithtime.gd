static func buffer_with_time_(
	timespan : float,
	timeshift = null,
	scheduler : SchedulerBase = null
) -> Callable:
	if timeshift == null:
		timeshift = timespan
	
	return GDRx.pipe.compose2(
		GDRx.op.window_with_time(timespan, timeshift, scheduler),
		GDRx.op.flat_map(GDRx.op.to_list())
	)
