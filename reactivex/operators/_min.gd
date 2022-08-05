static func first_only(x : Array):
	if x.is_empty():
		return GDRx.err.SequenceContainsNoElementsException.new()
	return x[0]

static func min_(
	comparer = null
) -> Callable:
	
	return GDRx.pipe.compose2(
		GDRx.op.min_by(GDRx.basic.identity, comparer),
		GDRx.op.map(func(x): return first_only(x))
	)
