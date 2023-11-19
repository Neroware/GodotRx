static func interval_(
	period : float,
	scheduler : SchedulerBase = null
) -> ObservableBase:
	
	return GDRx.obs.timer(period, period, scheduler)
