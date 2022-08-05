static func is_empty_() -> Callable:
	var mapper = func(b : bool) -> bool:
		return not b
	
	return GDRx.pipe.compose2(
		GDRx.op.some(),
		GDRx.op.map(mapper)
	)
