static func on_error_resume_next_(
	second : Observable
) -> Callable:
	var on_error_resume_next = func(source : Observable) -> Observable:
		return GDRx.obs.on_error_resume_next([source, second])
	
	return on_error_resume_next
