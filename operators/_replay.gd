static func replay_(
	mapper = null,
	buffer_size = null,
	window = null,
	scheduler : SchedulerBase = null
) -> Callable:
	
	if mapper != null:
		
		var subject_factory = func(
			scheduler : SchedulerBase
		) -> BehaviorSubject:
			var _buffer_size : int = buffer_size
			var _window : float = window
			return ReplaySubject.new(_buffer_size, _window, scheduler)
		
		return GDRx.op.multicast(
			null, subject_factory, mapper
		)
	
	var _buffer_size : int = buffer_size
	var _window : float = window
	var rs : ReplaySubject = ReplaySubject.new(_buffer_size, _window, scheduler)
	return GDRx.op.multicast(rs)
