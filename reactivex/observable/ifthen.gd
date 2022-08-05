static func if_then_(
	then_source : Observable,
	else_source : Observable = null,
	condition : Callable = func() -> bool: return true
) -> Observable:
	
	var else_source_ = else_source if else_source != null else GDRx.obs.empty()
	
	var factory = func(__ : SchedulerBase) -> Observable:
		return then_source if condition.call() else else_source_
	
	return GDRx.obs.defer(factory)
