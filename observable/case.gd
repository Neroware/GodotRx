static func case_(
	mapper : Callable,
	sources : Dictionary,
	default_source : Observable = null
) -> Observable:
	
	var default_source_ : Observable = default_source if default_source != null else GDRx.obs.empty()
	
	var factory = func(__ : SchedulerBase) -> Observable:
		var key_ = mapper.call()
		var result
		if not key_ in sources.keys():
			result = default_source_
		else:
			result = sources[key_]
		
		if not result is Observable:
			return GDRx.exc.BadMappingException.Throw()
		
		return result
	
	return GDRx.obs.defer(factory)
