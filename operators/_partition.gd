static func partition_(
	predicate : Callable = func(x): return true
) -> Callable:
	
	var partition = func(source : Observable) -> Array[Observable]:
	
		var not_predicate = func(x) -> bool:
			return not predicate.call(x)
		
		var published = source.pipe2(
			GDRx.op.publish(),
			GDRx.op.ref_count()
		)
		return [
			published.pipe(GDRx.op.filter(predicate)),
			published.pipe(GDRx.op.filter(not_predicate))
		]
	
	return partition

static func partition_indexed_(
	predicate_indexed : Callable = func(x): return true
) -> Callable:
	
	var partition_indexed = func(source : Observable) -> Array[Observable]:
	
		var not_predicate_indexed = func(x, i : int) -> bool:
			return not predicate_indexed.call(x, i)
		
		var published = source.pipe2(
			GDRx.op.publish(),
			GDRx.op.ref_count()
		)
		return [
			published.pipe(GDRx.op.filter_indexed(predicate_indexed)),
			published.pipe(GDRx.op.filter_indexed(not_predicate_indexed))
		]
	
	return partition_indexed
