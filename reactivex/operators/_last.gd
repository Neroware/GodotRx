static func last_(predicate = null) -> Callable:
	var last = func(source : Observable) -> Observable:
		if predicate != null:
			var predicate_ : Callable = predicate
			return source.pipe2(
				GDRx.op.filter(predicate_),
				GDRx.op.last()
			)
		
		return GDRx.op.last_or_default_async(source, false)
	
	return last
