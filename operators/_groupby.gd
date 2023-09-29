static func group_by_(
	key_mapper : Callable,
	element_mapper = null,
	subject_mapper = null
) -> Callable:
	
	var duration_mapper = func(__ : GroupedObservable) -> Observable:
		return GDRx.obs.never()
	
	return GDRx.op.group_by_until(
		key_mapper, duration_mapper, 
		element_mapper, subject_mapper
	)
