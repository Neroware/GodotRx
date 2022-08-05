static func sum_(
	key_mapper = null
) -> Callable:
	if key_mapper != null:
		var key_mapper_ : Callable = key_mapper
		return GDRx.pipe.compose2(GDRx.op.map(key_mapper_), GDRx.op.sum())
	
	var accumulator = func(prev : float, curr : float) -> float:
		return prev + curr
	
	return GDRx.op.reduce(accumulator, 0)
