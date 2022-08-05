static func contains_(
	value,
	comparer = GDRx.basic.default_comparer
) -> Callable:
	
	var predicate = func(v) -> bool:
		return comparer.call(v, value)
	
	return GDRx.pipe.compose2(
		GDRx.op.filter(predicate),
		GDRx.op.some()
	)
