static func max_by_(
	key_mapper : Callable,
	comparer = null
) -> Callable:
	var cmp = comparer if comparer != null else GDRx.basic.default_sub_comparer
	
	var max_by = func(source : Observable) -> Observable:
		return GDRx.op.extrema_by(source, key_mapper, cmp)
	
	return max_by
