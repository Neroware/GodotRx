static func all_(predicate : Callable) -> Callable:
	var filter = func(v):
		return not predicate.call(v)
	
	var mapping = func(b : bool) -> bool:
		return not b
	
	return GDRx.pipe.compose3(
		GDRx.op.filter(filter),
		GDRx.op.some(),
		GDRx.op.map(mapping)
	)
