static func publish_(mapper = null) -> Callable:
#	"""Returns an observable sequence that is the result of invoking the
#	mapper on a connectable observable sequence that shares a single
#	subscription to the underlying sequence. This operator is a
#	specialization of Multicast using a regular Subject.
#
#	Example:
#		>>> var res = GDRx.op.publish()
#		>>> var res = GDRx.op.publish(func(x): return x)
#
#	mapper: [Optional] Selector function which can use the
#		multicasted source sequence as many times as needed, without causing
#		multiple subscriptions to the source sequence. Subscribers to the
#		given source will receive all notifications of the source from the
#		time of the subscription on.
#
#	Returns:
#		An observable sequence that contains the elements of a sequence
#		produced by multicasting the source sequence within a mapper
#		function.
#	"""
	if mapper != null:
		var factory = func(_scheduler : SchedulerBase = null) -> Subject:
			return Subject.new()
		
		return GDRx.op.multicast(null, factory, mapper)
	
	var subject : Subject = Subject.new()
	return GDRx.op.multicast(subject)

static func share_() -> Callable:
#	"""Share a single subscription among multple observers.
#
#	Returns a new Observable that multicasts (shares) the original
#	Observable. As long as there is at least one Subscriber this
#	Observable will be subscribed and emitting data. When all
#	subscribers have unsubscribed it will unsubscribe from the source
#	Observable.
#
#	This is an alias for a composed publish() and ref_count().
#	"""
	return GDRx.pipe.compose2(
		GDRx.op.publish(),
		GDRx.op.ref_count()
	)
