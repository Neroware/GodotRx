static func single_(
	predicate = null
) -> Callable:
	
	if predicate != null:
		var _predicate : Callable = predicate
		return GDRx.pipe.compose2(
			GDRx.op.filter(_predicate),
			GDRx.op.single()
		)
	else:
		return GDRx.op.single_or_default_async(false)
