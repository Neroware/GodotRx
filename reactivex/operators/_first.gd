static func first_(
	predicate = null
) -> Callable:
	if predicate != null:
		var predicate_ : Callable = predicate
		return GDRx.pipe.compose2(GDRx.op.filter(predicate_), GDRx.op.first())
	
	return GDRx.op.first_or_default_async(false)
