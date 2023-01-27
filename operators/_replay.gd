static func replay_(
	mapper = null,
	buffer_size = null,
	window = null,
	scheduler : SchedulerBase = null
) -> Callable:
#	"""Returns an observable sequence that is the result of invoking the
#	mapper on a connectable observable sequence that shares a single
#	subscription to the underlying sequence replaying notifications
#	subject to a maximum time length for the replay buffer.
#
#	This operator is a specialization of Multicast using a
#	ReplaySubject.
#
#	Examples:
#		>>> var res = GDRx.op.replay(null, 3)
#		>>> var res = GDRx.op.replay(null, 3, 500)
#		>>> var res = GDRx.op.replay(func(x): return x.pipe2(GDRx.op.take(6), GDRx.op.repeat()), 3, 500)
#
#	Args:
#		mapper: [Optional] Selector function which can use the multicasted
#			source sequence as many times as needed, without causing
#			multiple subscriptions to the source sequence. Subscribers to
#			the given source will receive all the notifications of the
#			source subject to the specified replay buffer trimming policy.
#		buffer_size: [Optional] Maximum element count of the replay
#			buffer.
#		window: [Optional] Maximum time length of the replay buffer.
#		scheduler: [Optional] Scheduler the observers are invoked on.
#
#	Returns:
#		An observable sequence that contains the elements of a
#	sequence produced by multicasting the source sequence within a
#	mapper function.
#	"""
	if mapper != null:
		
		var subject_factory = func(
			scheduler : SchedulerBase
		) -> ReplaySubject:
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
