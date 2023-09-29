static func delay_subscription_(
	duetime : float,
	time_absolute : bool = false,
	scheduler : SchedulerBase = null
) -> Callable:
	var delay_subscription = func(source : Observable) -> Observable:
#		"""Time shifts the observable sequence by delaying the subscription.
#
#		Examples.
#			>>> var res = source.pipe1(GDRx.op.delay_subscription(5))
#
#		Args:
#			source: Source subscription to delay.
#
#		Returns:
#			Time-shifted sequence.
#		"""
		var mapper = func(__) -> Observable:
			return GDRx.obs.empty()
		
		return source.pipe1(
			GDRx.op.delay_with_mapper(GDRx.obs.timer(duetime, time_absolute, null, scheduler), mapper)
		)
	
	return delay_subscription
