static func with_latest_from_(
	sources : Array[Observable]
) -> Callable:
	var with_latest_from = func(source : Observable) -> Observable:
		return GDRx.obs.with_latest_from(source, sources)
	return with_latest_from
