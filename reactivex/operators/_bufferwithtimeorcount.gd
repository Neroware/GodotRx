static func buffer_with_time_or_count_(
	timespan : float,
	count : int,
	scheduler : SchedulerBase = null
) -> Callable:
	return GDRx.pipe.compose2(
		GDRx.op.window_with_time_or_count(timespan, count, scheduler),
		GDRx.op.flat_map(GDRx.op.to_iterable()),
	)
