static func count_(
	predicate = null
) -> Callable:
	
	if predicate != null:
		var predicate_ : Callable = predicate
		return GDRx.pipe.compose2(
			GDRx.op.filter(predicate_),
			GDRx.op.count()
		)
	
	var reducer = func(n, __) -> int:
		return n + 1
	
	var counter = GDRx.op.reduce(reducer, 0)
	return counter
