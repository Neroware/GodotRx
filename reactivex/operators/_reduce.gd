static func reduce_(
	accumulator : Callable, seed = GDRx.util.GetNotSet()
) -> Callable:
	if !(seed is GDRx.util.NotSet):
		var seed_ = seed
		var scanner = GDRx.op.scan(accumulator, seed_)
		return GDRx.pipe.compose2(
			scanner,
			GDRx.op.last_or_default(seed_)
		)
	
	return GDRx.pipe.compose2(
		GDRx.op.scan(accumulator),
		GDRx.last()
	)
