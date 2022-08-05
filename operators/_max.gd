static func max_(comparer = null) -> Callable:
	return GDRx.pipe.compose2(
		GDRx.op.max_by(GDRx.basic.identity, comparer),
		GDRx.op.map(func(x : Array): return GDRx.op._Min_.first_only(x))
	)

